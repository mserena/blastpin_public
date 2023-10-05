import 'package:blastpin/prefabs/loading_indicator.dart';
import 'package:blastpin/services/services_loader.dart';
import 'package:flutter/material.dart';

class LoaderPage extends StatefulWidget {
  final String route;

  const LoaderPage({super.key, required this.route});

  @override
  State<LoaderPage> createState() => _LoaderPage();
}

class _LoaderPage extends State<LoaderPage>{

  @override
  void initState() {
    ServicesLoader().loadServices(useFirebaseEmulator: true).then((value){
      if(ServicesLoader().isServicesLoaded()){
        Navigator.pushNamed(context, widget.route);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: createCenterLogoLoader(context),
      ),
    );
  }
}