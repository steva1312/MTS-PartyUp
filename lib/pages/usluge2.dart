import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mts_partyup/data.dart';
import 'package:mts_partyup/pages/usluga.dart';

class Usluge2 extends StatefulWidget {
  final TipUsluge tipUsluge;
  final List<Usluga2> usluge;
  final Map<String, String> profilePicturesUrls;
  final bool? isOwner;

  const Usluge2({
    super.key, 
    required this.tipUsluge,
    required this.usluge,
    required this.profilePicturesUrls,
    required this.isOwner
  });

  @override
  State<Usluge2> createState() => _Usluge2State();
}

class _Usluge2State extends State<Usluge2> {
  final uslugeRef = FirebaseDatabase.instance.ref('Usluge');
  final rezervacijeRef = FirebaseDatabase.instance.ref('Rezervacije');
  DataSnapshot? rezervacijeSnapshot;
  bool? isOwner;

  String datumText = '';
  String searchText = '';

  final searchController = TextEditingController();
  final datumController = TextEditingController();

  String inputGrad = gradovi[0];

  String text = 'Usluge';

  List<Usluga2> usluge = [];
  List<Usluga2> uslugeNotTemp = [];

  Map<String, String> profilePicturesUrls = {};

  bool sortirajPoOceni = false;

  @override
  void initState() {
    super.initState();
    filterUsluge();
  }

  void filterUsluge() {
    for (Usluga2 usluga in widget.usluge) {
      if (usluga.tipUsluge == widget.tipUsluge) {
        setState(() {
          usluge.add(usluga);
          uslugeNotTemp.add(usluga);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(context),
      body: _body(context),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          uslugaToString(widget.tipUsluge),
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        elevation: 0.0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
            )),
        actions: [
          IconButton(
            onPressed: () async {
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => buildSheet());
            },
            icon: const Icon(
              Icons.filter_list_outlined,
              color: Colors.black,
            ),
          )
        ]);
  }

  Widget makeDismissible({required Widget child}) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: GestureDetector(
          onTap: () {},
          child: child,
        ),
      );

  Widget buildSheet() => makeDismissible(
        child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            maxChildSize: 0.5,
            minChildSize: 0.1,
            builder: (_, controller) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: ListView(
                    controller: controller,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: 'Pretrazi',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onChanged: (String value) {
                          setState(() {
                            searchController.text = value;
                            searchText = value;
                            prikaziUsluge();
                          });
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      DropdownButtonFormField(
                          items: gradovi
                              .map((o) => DropdownMenuItem(
                                    value: o,
                                    child: Text(o),
                                  ))
                              .toList(),
                          decoration: const InputDecoration(
                            labelText: 'Grad',
                            prefixIcon: Icon(Icons.location_on_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                          ),
                          value: inputGrad,
                          onChanged: (String? newValue) {
                            setState(() {
                              inputGrad = newValue!;
                              prikaziUsluge();
                            });
                          }),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: datumController,
                        decoration: InputDecoration(
                          labelText: 'Slobodan datum',
                          prefixIcon: const Icon(Icons.date_range),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onChanged: (String value) {
                          setState(() {
                            datumController.text = value;
                            datumText = value;
                            prikaziUsluge();
                          });
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CheckboxListTile(
                        title: const Text('Sortiraj po oceni'),
                        value: sortirajPoOceni,
                        onChanged: (newValue) {
                          setState(() {
                            sortirajPoOceni = !sortirajPoOceni;
                            prikaziUsluge();
                          });
                        },
                        controlAffinity:
                        ListTileControlAffinity.leading, //  <-- leading Checkbox
                      ),
                    ],
                  ),
                )),
      );
  void prikaziUsluge() {
    setState(() {
      usluge.clear();
      for (Usluga2 sadusluga in uslugeNotTemp) {
        if (sadusluga.ime
                .toString()
                .toLowerCase()
                .contains(searchText.toLowerCase()) &&
            sadusluga.grad
                .toString()
                .toLowerCase()
                .contains(inputGrad.toLowerCase()) &&
            sadusluga.zauzetDatum.toString() != datumText) {
          usluge.add(sadusluga);
          if (sortirajPoOceni) {
            usluge.sort((a, b) => b.prosecnaOcena.compareTo(a.prosecnaOcena));
          }
        }
      }
    });
  }

  Widget _body(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ListView(
        children: usluge.map((u) => 
          
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                      
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => UslugaPage(
                        usluga: u, 
                        profilePictureUrl: widget.profilePicturesUrls[u.id]!,
                        isOwner: widget.isOwner,
                      ))
                    );
                  },
                  
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FadeInImage.assetNetwork(
                          image: widget.profilePicturesUrls[u.id]!,
                          placeholder: 'assets/icons/lokal.png',
                          fit: BoxFit.cover,
                          fadeInDuration: const Duration(milliseconds: 200),
                          fadeOutDuration: const Duration(milliseconds: 200),
                          fadeInCurve: Curves.easeIn,
                          fadeOutCurve: Curves.easeOut,
                          width: 100,
                          height: 100,
                        ),
                      ),
                      
                      const SizedBox(width: 20,),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            u.ime,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                            )
                          ),

                          const SizedBox(height: 2),

                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.map_pin,
                                size: 15,
                              ),
                              Text(
                                u.grad,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15
                                ),
                              ),
                            ] 
                          ),

                          const SizedBox(height: 7),

                          if (u.prosecnaOcena != 0)
                            Row(
                              children: [
                                Row(
                                  children: List.filled(
                                      u.prosecnaOcena.round(),
                                      Icon(
                                        Icons.star,
                                        color: Colors.yellow[600],
                                        size: 25,
                                      )),
                                ),

                                const SizedBox(
                                  width: 5,
                                ),

                                const Icon(
                                  Icons.person,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  u.ocene.length.toString(),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            )

                            else
                              const Text(
                                'Neocenjeno',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                    fontStyle: FontStyle.italic),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(
                  height: 15,
                ),
                if (usluge.indexOf(u) != usluge.length - 1)
                  Divider(
                    color: Colors.grey[200],
                  ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ).toList()
      ),
    );
  }
}
