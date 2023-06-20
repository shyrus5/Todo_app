import 'package:flutter/material.dart';
import 'package:todo_app/Function/db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
 
  List<Map<String,dynamic>>  _allData =[];
  bool _isLoading =true;

  void _refreshData() async {
    final data = await  SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading =false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }


 
  Future<void> _addData()async{
    await SQLHelper.createData(_titleController.text, _descController.text);
    _refreshData();
  }

  Future<void> _updatedData(int id)async{
    await SQLHelper.updateData(id,_titleController.text, _descController.text);
    _refreshData();
  }
  Future<void> _deleteData(int id)async{
    await SQLHelper.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Data deleted")
      )
    );
    _refreshData();
  }
  final TextEditingController _titleController =TextEditingController();
  final TextEditingController _descController =TextEditingController();

  void showBottomSheet(int? id )async {
    if(id !=null){
      final existingData =
                    _allData.firstWhere((element) => element['id']==id);
                    _titleController.text= existingData['title'];
                    _descController.text= existingData['desc'];
    }
    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) =>Container(
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom+50
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Title'
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Description'
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (id == null){
                    await _addData();
                  }
                  if(id != null){
                    await _updatedData(id);
                  }
                  _titleController.text ="";
                  _descController.text ="";

                  Navigator.of(context).pop();


                },
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    id==null ? 'Adda Data': "Update",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      )
    );
  }
  
  
  
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: const Color(0xFFECEAF4) ,
      appBar: AppBar(
        title: const Text("TODO APP"),
      ),
      body: _isLoading 
            ? const Center(
              child: CircularProgressIndicator(),
            ):
            ListView.builder(
              itemCount: _allData.length,
              itemBuilder: (context,index)=> Card(
                margin: const EdgeInsets.all(15),
                child: ListTile(
                  title: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5
                    ),
                    child: Text(
                      _allData[index]['title'],
                      style: const TextStyle(
                        fontSize: 20,

                      ),
                    ),
                  ),
                  subtitle: Text(_allData [index]['desc']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: (){
                          showBottomSheet(_allData[index]['id']);
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.indigo,
                        )
                      ),
                       IconButton(
                        onPressed: (){
                          _deleteData(_allData [index]['id']);
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                        )
                      )
                    ],
                  ),
                ),
              )
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: ()=> showBottomSheet(null),
              child: const Icon(Icons.add),
            ),

    );
  }
}
