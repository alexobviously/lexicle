import 'package:common/common.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class UserDetails extends StatelessWidget {
  final User user;
  const UserDetails({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.95,
      child: Neumorphic(
        style: const NeumorphicStyle(
          depth: -4.0,
          // boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(user.username, style: textTheme.headline5),
            Text('Rank: Wood 1'),
          ],
        ),
      ),
    );
  }
}
