import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  final Color darkBlue = const Color(0xFF2B4263);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.menu, color: Colors.black),
        actions: [Icon(Icons.notifications_none, color: Colors.black), SizedBox(width: 15)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2_outlined, size: 40, color: darkBlue),
                SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Help Center", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("Something looking for you", style: TextStyle(fontSize: 12, color: darkBlue)),
                ])
              ],
            ),
            
            Spacer(),
            
            Text("How can we help you today?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 20),

            // Input Box Besar
            Container(
              height: 100,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Color(0xFFE0E0E0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(0),
                ),
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(".....", style: TextStyle(color: Colors.grey)),
              ),
            ),
            
            SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: darkBlue),
                  child: Text("Undo", style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: darkBlue),
                  child: Text("Send", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}