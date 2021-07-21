import 'package:flutter/material.dart';
import 'package:ras/models/Project.dart';
import 'package:ras/repositories/Project.dart';
import 'package:ras/route-args/ProjectBuilderArgs.dart';
import 'package:ras/route-args/ProjectViewArgs.dart';

class ProjectList extends StatefulWidget {
  const ProjectList({Key? key}) : super(key: key);

  @override
  _ProjectListState createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> {
  Future<List<Project>> _listProjects = ProjectRepository().getAll();
  bool isSearching = false;
  List<Project> toBeFiltered = [];
  bool filterByNewest = false;
  bool filterByOldest = false;

  init() async {
    _listProjects.then((value) {
      toBeFiltered = value;
    });
  }

  duplicateProject(Project model) {
     Project project = Project(
        '',
        model.projectName,
        model.dateOfProject,
        model.sownMode,
        model.region,
        model.minSwtDate,
        model.maxSwtDate,
        model.minSwtTemp,
        model.maxSwtTemp,
        model.avgNumberOfRains,
        model.totalNumberOfRains,
        model.seeds,
        model.validSurface,
        model.notValidSurface,
        model.emptyLand,
        model.orientation,
        model.minAltTerrain,
        model.maxAltTerrain,
        model.maxDistance,
        model.depth,
        model.ph,
        model.fractured,
        model.hummus,
        model.inclination,
        model.geodata,
      );
      Future response = ProjectRepository().create(project);
      response.then((value) {
        print('Success!!!! $value');
        setState(() {
          _listProjects = ProjectRepository().getAll();
        });
        
      });
      response.catchError((onError) => print('Error $onError'));
  }

  filterSearchResults(String query) {
    List<Project> dummySearchList = [];
    dummySearchList.addAll(toBeFiltered);
    if (query.isNotEmpty) {
      List<Project> dummyListData = [];
      dummySearchList.forEach((item) {
        if (item.projectName.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        toBeFiltered.clear();
        toBeFiltered.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        _listProjects = ProjectRepository().getAll();
        filterByNewest = false;
        filterByOldest = false;
      });
    }
  }

  filterByAttributes() {
    List<Project> dummySearchList = [];
    dummySearchList.addAll(toBeFiltered);
    if (filterByNewest) {
      dummySearchList.sort((a, b) {
        return a.dateOfProject.compareTo(b.dateOfProject);
      });
      setState(() {
        toBeFiltered.clear();
        toBeFiltered.addAll(dummySearchList);
      });
    } else if (filterByOldest) {
      dummySearchList.sort((a, b) {
        return b.dateOfProject.compareTo(a.dateOfProject);
      });
      setState(() {
        toBeFiltered.clear();
        toBeFiltered.addAll(dummySearchList);
      });
    } else {
      setState(() {
        _listProjects = ProjectRepository().getAll();
      });
    }
  }

  void filterBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter bottomState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter by',
                          style: TextStyle(color: Colors.white, fontSize: 25),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.clear,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CheckboxListTile(
                    title: Text('Newest'),
                    value: filterByNewest,
                    onChanged: (value) {
                      setState(() {
                        if (value != null) {
                          filterByNewest = !filterByNewest;
                          if (value) filterByOldest = false;
                        }
                      });

                      bottomState(() {});
                    }),
                CheckboxListTile(
                    title: Text('Oldest'),
                    value: filterByOldest,
                    onChanged: (value) {
                      setState(() {
                        if (value != null) {
                          filterByOldest = !filterByOldest;
                          if (value) filterByNewest = false;
                        }
                      });
                      bottomState(() {});
                    }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        filterByAttributes();
                      },
                      child: Text('Search')),
                )
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    init();

    return Stack(
      children: [
        Column(
          children: [
            !isSearching
                ? Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Projects',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _listProjects = ProjectRepository().getAll();
                                });
                              },
                              icon: Icon(Icons.refresh),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  isSearching = true;
                                });
                              },
                              icon: Icon(Icons.search),
                            ),
                            IconButton(
                              onPressed: () {
                                filterBottomSheet(context);
                              },
                              icon: Icon(Icons.filter_list),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextField(
                      onChanged: (value) {
                        filterSearchResults(value);
                      },
                      decoration: InputDecoration(
                        filled: true,
                        labelText: 'Search',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isSearching = false;
                              _listProjects = ProjectRepository().getAll();
                            });
                          },
                          icon: Icon(Icons.clear),
                        ),
                      ),
                    ),
                  ),
            Expanded(
              child: FutureBuilder(
                  future: _listProjects,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      List<Project> data = snapshot.data;

                      if (data.length <= 0)
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            'No results',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );

                      return ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/project-view',
                                    arguments: ProjectViewArgs(data[index]));
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                padding: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  border: Border(
                                    left: BorderSide(
                                        color: Colors.green, width: 10),
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(
                                    '${data[index].projectName}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Area covered: ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18),
                                              ),
                                              Text(
                                                'XXm',
                                                style: TextStyle(fontSize: 18),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Date: ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18),
                                              ),
                                              Text(
                                                '${data[index].dateOfProject.toString().substring(0, 10)}',
                                                style: TextStyle(fontSize: 18),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Region: ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18),
                                              ),
                                              Text(
                                                '${data[index].region}',
                                                style: TextStyle(fontSize: 18),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Species sown: ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18),
                                              ),
                                              for (var i = 0;
                                                  i < data[index].seeds.length;
                                                  i++)
                                                Text(
                                                  '${data[index].seeds[i].commonName} | density = ${data[index].seeds[i].density}%',
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            OutlinedButton.icon(
                                              onPressed: () {
                                                duplicateProject(data[index]);
                                              },
                                              icon: Icon(Icons.copy),
                                              label: Text('Duplicate'),
                                              style: OutlinedButton.styleFrom(
                                                primary: Colors.blue,
                                                side: BorderSide(
                                                    color: Colors.blue,
                                                    width: 1),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          });
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Column(
                        children: [
                          SizedBox(
                            child: CircularProgressIndicator(),
                            width: 60,
                            height: 60,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text('Loading data...'),
                          )
                        ],
                      );
                    }
                  }),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 30.0, right: 30.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/project-builder',
                    arguments: ProjectBuilderArgs(true));
              },
              child: Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}
