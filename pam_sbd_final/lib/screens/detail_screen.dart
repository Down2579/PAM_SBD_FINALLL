import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models.dart';
import '../providers.dart';
import '../api_service.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatelessWidget {
  final Item item;
  DetailScreen({required this.item});

  final TextEditingController _pesanController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final bool isMyItem = user != null && user.id == item.idPelapor;
    // Klaim hanya bisa jika bukan punya sendiri & status masih open & barang hilang
    final bool canClaim = !isMyItem && item.status == 'open' && item.tipeLaporan == 'hilang';

    return Scaffold(
      appBar: AppBar(title: Text("Detail Barang")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 200, width: double.infinity, color: Colors.grey[200], child: Icon(Icons.image, size: 80, color: Colors.grey)),
            SizedBox(height: 16),
            Text(item.namaBarang, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(children: [
              Chip(label: Text(item.tipeLaporan.toUpperCase())),
              SizedBox(width: 10),
              Chip(label: Text(item.status), backgroundColor: item.status == 'open' ? Colors.green[100] : Colors.red[100]),
            ]),
            Divider(height: 30),
            Text("Deskripsi:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(item.deskripsi),
            SizedBox(height: 10),
            Text("Lokasi: ${item.lokasi}"),
            Text("Tanggal: ${DateFormat('dd MMM yyyy').format(item.tanggalKejadian)}"),
            Text("Pelapor: ${item.pelaporNama}"),
            SizedBox(height: 30),
            
            if (canClaim) ...[
              Text("Ajukan Klaim", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(
                controller: _pesanController,
                decoration: InputDecoration(hintText: "Jelaskan ciri-ciri barang...", border: OutlineInputBorder()),
                maxLines: 2,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if (_pesanController.text.isEmpty) return;
                  try {
                    String res = await ApiService().claimItem(item.id, _pesanController.text);
                    if (res == "Berhasil") {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Klaim berhasil dikirim!")));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                },
                child: Container(width: double.infinity, alignment: Alignment.center, child: Text("KLAIM BARANG INI")),
              )
            ],

            if (isMyItem) Center(child: Text("Ini adalah laporan Anda.", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
            if (item.status != 'open') Center(child: Text("Status barang: ${item.status}", style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic))),
          ],
        ),
      ),
    );
  }
}