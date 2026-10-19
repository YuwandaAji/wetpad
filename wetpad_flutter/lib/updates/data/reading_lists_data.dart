import '../models/reading_list.dart';
import 'communities_data.dart';
import 'stories_data.dart';

class ReadingListsData {
  static const fromConnections = <ReadingList>[
    ReadingList(
      id: 'rl1',
      title: 'Romansa',
      owner: CommunitiesData.ambassadors,
      stories: [
        StoriesData.midnightLetters,
        StoriesData.duplicity,
        StoriesData.fireKing,
      ],
    ),
    ReadingList(
      id: 'rl2',
      title: 'Space Adventure',
      owner: CommunitiesData.action,
      stories: [
        StoriesData.virusWithin,
        StoriesData.raiseAssassin,
        StoriesData.hollowCrown,
      ],
    ),
    ReadingList(
      id: 'rl3',
      title: 'Fantasi',
      owner: CommunitiesData.ambassadors,
      stories: [
        StoriesData.hollowCrown,
        StoriesData.fireKing,
        StoriesData.whisperHouse,
      ],
    ),
  ];
}
