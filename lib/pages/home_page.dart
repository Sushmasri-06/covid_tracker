import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List countries = [];
  List filteredCountries = [];
  Map<String, dynamic>? globalData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future fetchData() async {
    try {
      // Fetch countries data
      var countriesUrl = Uri.parse('https://disease.sh/v3/covid-19/countries');
      var countriesResponse = await http.get(countriesUrl);

      // Fetch global data
      var globalUrl = Uri.parse('https://disease.sh/v3/covid-19/all');
      var globalResponse = await http.get(globalUrl);

      if (countriesResponse.statusCode == 200 && globalResponse.statusCode == 200) {
        List data = json.decode(countriesResponse.body);
        data.sort((a, b) => a['country'].toString().compareTo(b['country'].toString()));

        setState(() {
          countries = data;
          filteredCountries = data;
          globalData = json.decode(globalResponse.body);
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      // You can also show error message here if you want
    }
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      List dummyListData = [];
      for (var item in countries) {
        if (item['country'].toString().toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        filteredCountries = dummyListData;
      });
      return;
    } else {
      setState(() {
        filteredCountries = countries;
      });
    }
  }

  Widget globalSummary() {
    if (globalData == null) return Container();

    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatColumn("Cases", globalData!['cases']),
            _buildStatColumn("Recovered", globalData!['recovered']),
            _buildStatColumn("Deaths", globalData!['deaths']),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String title, int count) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(count.toString(), style: const TextStyle(fontSize: 18)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('COVID-19 Tracker'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                globalSummary(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) {
                      filterSearchResults(value);
                    },
                    decoration: const InputDecoration(
                      labelText: "Search Country",
                      hintText: "Enter country name",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0))),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredCountries.length,
                    itemBuilder: (context, index) {
                      var country = filteredCountries[index];
                      return ListTile(
                        leading: Image.network(
                          country['countryInfo']['flag'],
                          width: 50,
                        ),
                        title: Text(country['country']),
                        subtitle: Text(
                            'Cases: ${country['cases']} | Recovered: ${country['recovered']} | Deaths: ${country['deaths']}'),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

