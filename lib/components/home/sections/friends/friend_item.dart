import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotify/spotify.dart';
import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/components/shared/image/universal_image.dart';
import 'package:spotube/models/spotify_friends.dart';
import 'package:spotube/provider/spotify_provider.dart';

class FriendItem extends HookConsumerWidget {
  final SpotifyFriendActivity friend;
  const FriendItem({
    Key? key,
    required this.friend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final ThemeData(
      textTheme: textTheme,
      colorScheme: colorScheme,
    ) = Theme.of(context);

    final queryClient = useQueryClient();
    final spotify = ref.watch(spotifyProvider);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      constraints: const BoxConstraints(
        minWidth: 300,
      ),
      height: 80,
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: UniversalImage.imageProvider(
              friend.user.imageUrl,
            ),
          ),
          const Gap(8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                friend.user.name,
                style: textTheme.bodyLarge,
              ),
              RichText(
                text: TextSpan(
                  style: textTheme.bodySmall,
                  children: [
                    TextSpan(
                      text: friend.track.name,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          context.push("/track/${friend.track.id}");
                        },
                    ),
                    const TextSpan(text: " • "),
                    const WidgetSpan(
                      child: Icon(
                        SpotubeIcons.artist,
                        size: 12,
                      ),
                    ),
                    TextSpan(
                      text: " ${friend.track.artist.name}",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          context.push(
                            "/artist/${friend.track.artist.id}",
                          );
                        },
                    ),
                    const TextSpan(text: "\n"),
                    TextSpan(
                      text: friend.track.context.name,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          context.push(
                            "/${friend.track.context.path}",
                            extra: !friend.track.context.path
                                    .startsWith("album")
                                ? null
                                : await queryClient.fetchQuery<Album, dynamic>(
                                    "album/${friend.track.album.id}",
                                    () => spotify.albums.get(
                                      friend.track.album.id,
                                    ),
                                  ),
                          );
                        },
                    ),
                    const TextSpan(text: " • "),
                    const WidgetSpan(
                      child: Icon(
                        SpotubeIcons.album,
                        size: 12,
                      ),
                    ),
                    TextSpan(
                      text: " ${friend.track.album.name}",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          final album =
                              await queryClient.fetchQuery<Album, dynamic>(
                            "album/${friend.track.album.id}",
                            () => spotify.albums.get(
                              friend.track.album.id,
                            ),
                          );
                          if (context.mounted) {
                            context.push(
                              "/album/${friend.track.album.id}",
                              extra: album,
                            );
                          }
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
