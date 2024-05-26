import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Providers/useraddressprovider.dart';
import 'package:ridemate/utils/appcolors.dart';
import 'package:ridemate/widgets/spacing.dart';
import '../../../Providers/bookingprovider.dart';
import '../../../Providers/homeprovider.dart';
import '../../../widgets/customtext.dart';

void showsearchbottomsheet(BuildContext context, {bool ispickup = false}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Search(ispickup: ispickup),
      ),
    ),
  );
}

class Search extends StatefulWidget {
  final bool ispickup;
  const Search({super.key, required this.ispickup});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final myprovider = Provider.of<Homeprovider>(context, listen: false);
    controller.text = widget.ispickup ? myprovider.address : '';
    controller.addListener(() {
      myprovider.changeiconvisibility(controller.text.length);
      myprovider.getsuggesstion(controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      clipBehavior: Clip.none,
      children: [
        Positioned(
            top: -12,
            child: Container(
              width: 60,
              height: 7,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5), color: Colors.white),
            )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              addVerticalspace(height: 20),
              Consumer<Homeprovider>(
                builder: (context, myprovider, child) => TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: widget.ispickup
                        ? 'Search Pickup'
                        : 'Search your destination',
                    prefixIcon: const Icon(Icons.location_on),
                    suffixIcon: myprovider.showicon
                        ? IconButton(
                            onPressed: () {
                              controller.clear();
                            },
                            icon: const Icon(Icons.close))
                        : null,
                    fillColor: const Color(0xfffff1b1),
                    filled: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              addVerticalspace(height: 12),
              Consumer<Homeprovider>(
                builder: (context, value, child) => value.message ==
                        'nothingfound'
                    ? Column(
                        children: [
                          Image.asset('assets/nodata.png'),
                          const CustomText(
                            title: 'Not Found',
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          const CustomText(
                            title:
                                'Sorry, the keyword you entered cannot be\n found, please check again or search with\n another keyword',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : ListView.builder(
                        itemCount: value.suggestionlist.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: CustomText(
                              title: '${value.suggestionlist[index].maintext}',
                              overflow: TextOverflow.ellipsis,
                              color: Appcolors.contentTertiary,
                            ),
                            subtitle: CustomText(
                              title:
                                  '${value.suggestionlist[index].secondarytext}',
                              overflow: TextOverflow.ellipsis,
                              color: Appcolors.contentDisbaled,
                            ),
                            leading: const Icon(Icons.location_on),
                            onTap: () {
                              widget.ispickup
                                  ? Provider.of<Pickupaddress>(context,
                                          listen: false)
                                      .updatebyapi(
                                          '${value.suggestionlist[index].placeid}',
                                          context)
                                  : Provider.of<Destinationaddress>(context,
                                          listen: false)
                                      .updateaddress(
                                          '${value.suggestionlist[index].placeid}',
                                          context);
                              widget.ispickup
                                  ? value.changepickup(
                                      '${value.suggestionlist[index].maintext}')
                                  : value.changedest(
                                      '${value.suggestionlist[index].maintext}');
                              Provider.of<Bookingprovider>(context,
                                      listen: false)
                                  .checkifempty(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
