import 'package:flutter/material.dart';
import 'package:harajkhodar/models/category.dart';
import 'package:harajkhodar/utils/app_colors.dart';
import 'package:harajkhodar/utils/app_colors.dart';

class CategoryItem extends StatelessWidget {
  final CategoryModel category;
    final AnimationController animationController;
  final Animation animation;

  const CategoryItem({Key key, this.category, this.animationController, this.animation}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(

        margin: EdgeInsets.all(5),
        width: constraints.maxWidth *0.2,
        height: constraints.maxHeight *0.8,
        decoration: BoxDecoration(
          color: category.isSelected ?  Colors.white : mainAppColor,
          border: Border.all(
            width: 1.0,
            color: category.isSelected ? mainAppColor: mainAppColor,
          ),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),


        child: Column(
          children: <Widget>[
            Container(
              height: constraints.maxHeight *0.6,
              padding: EdgeInsets.all(7),
              child:  category.catId != '0' ?
              ClipRRect(
                  borderRadius: BorderRadius.all( Radius.circular(10.0)),
                  child: Image.network(category.catImage,color: category.isSelected ?mainAppColor:Colors.white,)) :
              Image.asset(category.catImage,color: category.isSelected ?mainAppColor:Colors.white,),
            ),
            Container(
              alignment: Alignment.center,
              width: constraints.maxWidth,
              child: Text(category.catName,style: TextStyle(

                color: category.isSelected ?mainAppColor:Colors.white,fontSize: category.catName.length > 1 ?13 : 13,

              ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,),
            ),

          ],
        ),
      );
    });
  }
}
