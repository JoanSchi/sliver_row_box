import 'package:flutter/material.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    const headerSize = 20.0;
    const paragraphSize = 18.0;

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 247, 250, 241),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            const Center(
                child: Text('About', style: TextStyle(fontSize: 24.0))),
            const SizedBox(
              height: 12.0,
            ),
            RichText(
                text: const TextSpan(
                    text:
                        'SliverRowBox is a implementation of SliverList, to animate the insertion or removal of multiple items at once.',
                    style:
                        TextStyle(fontSize: paragraphSize, color: Colors.black),
                    children: [
                  TextSpan(
                      text: '\n\nAnimals A-Z',
                      style: TextStyle(
                          fontSize: headerSize, color: Color(0xFF80ba27))),
                  TextSpan(
                      text:
                          '\nThe Animals A-Z box is simple example to demonstrate the insert or removal of multiple items. Use for the insertion a different color to recognize the new items.'),
                  TextSpan(
                      text: '\n\nUse',
                      style: TextStyle(
                          fontSize: headerSize, color: Color(0xFF80ba27))),
                  TextSpan(
                      text:
                          '\nThe SliverRowBox is used in Slivers to simulate a box, with header, items and bottom for < 50 items.'
                          ' Currently SliverRowBox is used for mortgage cost and renovation/sustainablility cost, the bottom is used for total cost and to add a items. It can also be used as shopping card, or boxes for householdbook.'
                          ' To prevent small lines between the items from the background, a background with some overlap is used. The action on the left is used to revert the selection.'),
                  TextSpan(
                      text: '\n\nInsertion/Removal',
                      style: TextStyle(
                          fontSize: headerSize, color: Color(0xFF80ba27))),
                  TextSpan(
                      text:
                          '\nIf items are inserted or removed, the SliverConstraints is retrieved to obtain the scrollOffset and the viewportMainAxisExtent to calculate which items to animate and which not.'
                          '\n\nThe items above the viewport are inserted and removed and the scrollOffset (pixels) are corrected in the ScrollPosition (Scrollable.of(context)?.position).'
                          ' The offset is scrolled 30 to notify the user that there was a insertion or removal.'
                          '\n\nThe items inserted or removed inside the viewport are animated. Nevertheless if a large amount of items is inserted the animation will is to fast to notice.'
                          'Therefore only the insertions visible after the animation will be animated, and the others items are delayed and inserted after the animation.'
                          ' If the user scrolls down during the animation, the delayed insertions will popup suddenly, for this rare case if desired a callback is availible to add a IgnorePointer widget.'),
                  TextSpan(
                      text: '\n\nSpeed/Scrollbar',
                      style: TextStyle(
                          fontSize: headerSize, color: Color(0xFF80ba27))),
                  TextSpan(
                      text:
                          '\nSliverList performs a layout of every child, therefore a long list is not ideal especially not in combination with scrollbar, therefore a replacement of modified SliverFixedExtentList would be better.'
                          ' At the moment the box is only used for modest amount of items, (Animal list is quite long). To minimize the layout calculation SizedSliverBox is kept simple: (not dependend on child), therefore the layout is fast enough for now.'
                          ' Nevertheless if the fixed sliver list is implement, the widget can be used with some modifications to animate long list. With some adjustemts the insert/remove can be animated at once for filters options for example.')
                ])),
          ],
        ),
      ),
    );
  }
}
