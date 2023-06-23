import 'package:flutter/material.dart';
import './util/dbhelper.dart';
import './models/shopping_list.dart';
import './UI/items_screen.dart';
import './UI/shopping_list_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const ShList(),
    );
  }
}

class ShList extends StatefulWidget {
  const ShList({super.key});

  @override
  _ShListState createState() => _ShListState();
}

class _ShListState extends State<ShList> {
  List<ShoppingList> shoppingList = [];
  DbHelper helper = DbHelper();
  ShoppingListDialog dialog = ShoppingListDialog();

  @override
  void initState() {
    super.initState();
    showData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
      ),
      body: ListView.builder(
        itemCount: shoppingList.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(shoppingList[index].name),
            onDismissed: (direction) {
              String strName = shoppingList[index].name;
              helper.deleteList(shoppingList[index]);
              setState(() {
                shoppingList.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$strName deleted")),
              );
            },
            child: ListTile(
              title: Text(shoppingList[index].name),
              leading: CircleAvatar(
                child: Text(shoppingList[index].priority.toString()),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemsScreen(shoppingList[index]),
                  ),
                );
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => dialog.buildDialog(
                          context,
                          shoppingList[index],
                          false,
                          (name, priority) {
                            editShoppingList(
                                shoppingList[index], name, priority);
                          },
                        ),
                      ).then((_) {
                        showData(); // Refresh the list after editing
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      deleteShoppingList(shoppingList[index]);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => dialog.buildDialog(
              context,
              ShoppingList(0, '', 0),
              true,
              (name, priority) {
                addShoppingList(name, priority);
              },
            ),
          ).then((_) {
            showData(); // Refresh the list after adding a new shopping list
          });
        },
        backgroundColor: Colors.greenAccent[400],
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> showData() async {
    await helper.openDb();
    List<ShoppingList> lists = await helper.getLists();
    setState(() {
      shoppingList = lists;
    });
  }

  void addShoppingList(String name, int priority) {
    ShoppingList shoppingList = ShoppingList(0, name, priority);
    helper.insertList(shoppingList).then((savedListId) {
      if (savedListId > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Shopping list saved")),
        );
      }
    });
  }

  void editShoppingList(ShoppingList list, String name, int priority) {
    list.name = name;
    list.priority = priority;
    helper.updateList(list).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Shopping list updated")),
      );
      showData(); // Refresh the list after editing
    });
  }

  void deleteShoppingList(ShoppingList list) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Shopping List"),
          content:
              const Text("Are you sure you want to delete this shopping list?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                helper.deleteList(list).then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Shopping list deleted")),
                  );
                  showData(); // Refresh the list after deletion
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
