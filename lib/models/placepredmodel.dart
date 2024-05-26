class Placepredmodel {
  String? secondarytext;
  String? maintext;
  String? placeid;
  Placepredmodel({
    this.secondarytext,
    this.maintext,
    this.placeid,
  });
  Placepredmodel.fromjson(Map<String, dynamic> json) {
    placeid = json['place_id'];
    maintext = json['structured_formatting']['main_text'];
    secondarytext = json['structured_formatting']['secondary_text'];
  }
}
