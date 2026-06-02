pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    property int mediaRevision: 0
    property real currentPosition: 0

    readonly property var player: findPlayer()
    readonly property bool hasPlayer: player !== null
    readonly property bool isPlaying: isPlayerPlaying(player)
    readonly property string title: cleanText(player?.trackTitle ?? "")
    readonly property string artist: cleanText(player?.trackArtist ?? "")
    readonly property string artUrl: {
        mediaRevision;
        return findCurrentArtUrl();
    }
    readonly property string displayText: buildDisplayText()
    readonly property real infiniteTrackLength: 922337203685
    readonly property real trackLength: player !== null && player.length < infiniteTrackLength ? player.length : 0
    readonly property bool hasProgress: trackLength > 0
    readonly property real progress: {
        if (!hasProgress) {
            return 0;
        }

        const ratio = currentPosition / trackLength;
        if (isNaN(ratio) || !isFinite(ratio)) {
            return 0;
        }

        return Math.max(0, Math.min(1, ratio));
    }
    readonly property bool canPlay: !!player?.canPlay
    readonly property bool canPause: !!player?.canPause
    readonly property bool canTogglePlaying: !!player?.canTogglePlaying
    readonly property bool canGoNext: !!player?.canGoNext
    readonly property bool canGoPrevious: !!player?.canGoPrevious

    Connections {
        target: Mpris.players

        function onValuesChanged(): void {
            root.mediaRevision += 1;
        }
    }

    Connections {
        target: root.player

        function onMetadataChanged(): void {
            root.mediaRevision += 1;
        }

        function onTrackArtUrlChanged(): void {
            root.mediaRevision += 1;
        }

        function onPositionChanged(): void {
            root.updateCurrentPosition();
        }

        function onPlaybackStateChanged(): void {
            root.updateCurrentPosition();
        }

        function onTrackChanged(): void {
            root.mediaRevision += 1;
            root.updateCurrentPosition();
        }
    }

    onPlayerChanged: updateCurrentPosition()

    Timer {
        interval: 1000
        repeat: true
        running: root.player !== null && root.isPlaying && root.hasProgress

        onTriggered: root.updateCurrentPosition()
    }

    function updateCurrentPosition(): void {
        currentPosition = player ? player.position : 0;
    }

    function cleanText(value: string): string {
        return String(value ?? "").replace(/(\r\n|\n|\r)/g, "").trim();
    }

    function isPlayerPlaying(candidate: var): bool {
        return !!candidate && (candidate.isPlaying || candidate.playbackState === MprisPlaybackState.Playing);
    }

    function hasTrackInfo(candidate: var): bool {
        return cleanText(candidate?.trackTitle ?? "").length > 0 || cleanText(candidate?.trackArtist ?? "").length > 0;
    }

    function findArtUrl(candidate: var): string {
        if (!candidate) {
            return "";
        }

        const trackArtUrl = cleanText(candidate.trackArtUrl ?? "");
        if (trackArtUrl.length > 0) {
            return trackArtUrl;
        }

        const metadata = candidate.metadata;
        if (!metadata) {
            return "";
        }

        const metadataArtUrl = cleanText(metadata["mpris:artUrl"] ?? "");
        if (metadataArtUrl.length > 0) {
            return metadataArtUrl;
        }

        for (const key of Object.keys(metadata)) {
            if (key === "mpris:artUrl") {
                return cleanText(metadata[key] ?? "");
            }
        }

        return "";
    }

    function findCurrentArtUrl(): string {
        const playerArtUrl = findArtUrl(player);
        if (playerArtUrl.length > 0) {
            return playerArtUrl;
        }

        if (!Mpris.players || !Mpris.players.values) {
            return "";
        }

        for (const candidate of Mpris.players.values) {
            const candidateArtUrl = findArtUrl(candidate);
            if (candidateArtUrl.length > 0) {
                return candidateArtUrl;
            }
        }

        return "";
    }

    function findPlayer(): var {
        if (!Mpris.players || !Mpris.players.values) {
            return null;
        }

        const players = Mpris.players.values;
        let fallback = null;

        for (const candidate of players) {
            if (!candidate) {
                continue;
            }

            if (isPlayerPlaying(candidate)) {
                return candidate;
            }

            if (fallback === null && hasTrackInfo(candidate)) {
                fallback = candidate;
            }
        }

        return fallback ?? (players[0] ?? null);
    }

    function buildDisplayText(): string {
        if (!hasPlayer) {
            return "";
        }

        if (artist.length > 0 && title.length > 0) {
            return artist + " - " + title;
        }
        if (title.length > 0) {
            return title;
        }
        if (artist.length > 0) {
            return artist;
        }
        return "";
    }

    function play(): void {
        if (player?.canPlay) {
            player.play();
        }
    }

    function pause(): void {
        if (player?.canPause) {
            player.pause();
        }
    }

    function togglePlaying(): void {
        if (!player) {
            return;
        }

        if (player.canTogglePlaying) {
            player.togglePlaying();
            return;
        }

        if (isPlaying) {
            pause();
        } else {
            play();
        }
    }

    function next(): void {
        if (player?.canGoNext) {
            player.next();
        }
    }

    function previous(): void {
        if (player?.canGoPrevious) {
            player.previous();
        }
    }
}
