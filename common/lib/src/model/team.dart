import 'package:common/common.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'team.g.dart';

@CopyWith()
class Team implements Entity {
  @override
  final String id;
  @override
  final int timestamp;
  final String name;
  final String leader;
  final List<String> members;

  Team({
    String? id,
    int? timestamp,
    required this.name,
    required this.leader,
    this.members = const [],
  })  : id = id ?? ObjectId().id.hexString,
        timestamp = timestamp ?? nowMs();

  factory Team.fromJson(Map<String, dynamic> doc) => Team(
        id: doc[Fields.id],
        timestamp: doc[Fields.timestamp] ?? nowMs(),
        name: doc[TeamFields.name],
        leader: doc[TeamFields.leader],
        members: coerceList<String>(doc[TeamFields.members] ?? []),
      );

  Map<String, dynamic> toMap({bool includeMembers = true}) => {
        Fields.id: id,
        Fields.timestamp: timestamp,
        TeamFields.name: name,
        TeamFields.leader: leader,
        if (includeMembers) TeamFields.members: members,
      };

  @override
  Map<String, dynamic> export() => toMap();

  Team addMember(String id) => copyWith(members: List.from(members)..add(id));
  Team removeMember(String id) => copyWith(members: List.from(members)..remove(id));
}
