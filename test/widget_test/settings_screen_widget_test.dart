import 'package:bloc_test/bloc_test.dart';
import 'package:flood_mobile/Blocs/sse_bloc/sse_bloc.dart';
import 'package:flood_mobile/Model/client_settings_model.dart';
import 'package:flood_mobile/Model/current_user_detail_model.dart';
import 'package:flood_mobile/Pages/settings_screen/settings_screen.dart';
import 'package:flood_mobile/Blocs/theme_bloc/theme_bloc.dart';
import 'package:flood_mobile/Pages/settings_screen/widgets/settings_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flood_mobile/Blocs/client_settings_bloc/client_settings_bloc.dart';
import 'package:flood_mobile/Blocs/home_screen_bloc/home_screen_bloc.dart';
import 'package:flood_mobile/Blocs/user_detail_bloc/user_detail_bloc.dart';

class MockUserDetailBloc extends MockBloc<UserDetailEvent, UserDetailState>
    implements UserDetailBloc {}

class MockClientSettingsBloc
    extends MockBloc<ClientSettingsEvent, ClientSettingsState>
    implements ClientSettingsBloc {}

void main() {
  late UserDetailBloc mockUserDetailBloc;
  late MockClientSettingsBloc mockClientSettingsBloc;

  tearDown(() {});
  setUp(() {
    mockUserDetailBloc = MockUserDetailBloc();
    mockClientSettingsBloc = MockClientSettingsBloc();

    when(() => mockUserDetailBloc.usersList).thenReturn([
      CurrentUserDetailModel(username: 'test username 1', level: 1),
      CurrentUserDetailModel(username: 'test username 2', level: 2),
    ]);
    when(() => mockUserDetailBloc.token).thenReturn('token');
    when(() => mockUserDetailBloc.username).thenReturn('test username 1');

    when(() => mockUserDetailBloc.state).thenReturn(
      UserDetailLoaded(
        token: 'token',
        username: 'test username 1',
        usersList: [
          CurrentUserDetailModel(username: 'test username 1', level: 1),
          CurrentUserDetailModel(username: 'test username 2', level: 2),
        ],
      ),
    );

    when(() => mockClientSettingsBloc.clientSettings).thenReturn(
      ClientSettingsModel(
        dht: true,
        dhtPort: 8080,
        directoryDefault: 'test directory',
        networkHttpMaxOpen: 500,
        networkLocalAddress: ['test networkLocalAddress'],
        networkMaxOpenFiles: 100,
        networkPortOpen: true,
        networkPortRandom: true,
        networkPortRange: 'test networkPortRange',
        piecesHashOnCompletion: false,
        piecesMemoryMax: 512,
        protocolPex: false,
        throttleGlobalDownSpeed: 1024,
        throttleGlobalUpSpeed: 2048,
        throttleMaxDownloads: 7,
        throttleMaxDownloadsGlobal: 12,
        throttleMaxUploads: 5,
        throttleMaxUploadsGlobal: 10,
        throttleMinPeersNormal: 15,
        throttleMaxPeersNormal: 50,
        throttleMinPeersSeed: 20,
        throttleMaxPeersSeed: 100,
        trackersNumWant: 10,
      ),
    );
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
        providers: [
          BlocProvider<UserDetailBloc>.value(
            value: mockUserDetailBloc,
          ),
          BlocProvider<HomeScreenBloc>.value(
            value: HomeScreenBloc(),
          ),
          BlocProvider<SSEBloc>.value(
            value: SSEBloc(),
          ),
          BlocProvider<ClientSettingsBloc>.value(
            value: mockClientSettingsBloc,
          ),
          BlocProvider<ThemeBloc>.value(
            value: ThemeBloc(),
          ),
        ],
        child: MaterialApp(
            home: Material(
          child: SettingsScreen(themeIndex: 2),
        )));
  }

  testWidgets("Check if initial options displayed",
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Settings'), findsOneWidget);
    expect(find.byIcon(Icons.wifi_rounded), findsOneWidget);
    expect(find.text('Bandwidth'), findsOneWidget);
    expect(find.byIcon(FontAwesomeIcons.connectdevelop), findsOneWidget);
    expect(find.text('Connectivity'), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.text('Resources'), findsOneWidget);
    expect(find.byIcon(Icons.speed_rounded), findsOneWidget);
    expect(find.text('Speed Limit'), findsOneWidget);
    expect(find.byIcon(Icons.security), findsOneWidget);
    expect(find.text('Authentication'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.byIcon(Icons.save), findsOneWidget);
  });

  testWidgets('Check Bandwidth Section', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byKey(Key('Bandwidth Expansion Card')), findsOneWidget);
    expect(find.byKey(Key('Bandwidth option display column')), findsOneWidget);
    expect(find.byType(SettingsTextField), findsNWidgets(6));
    expect(find.byIcon(FontAwesomeIcons.connectdevelop), findsOneWidget);
    expect(find.text('Transfer Rate Throttles'), findsOneWidget);
    expect(find.text('Global Download Rate Throttle'), findsNWidgets(2));
    expect(find.text('1024'), findsOneWidget);
    expect(find.text('Global Upload Rate Throttle'), findsNWidgets(2));
    expect(find.text('2048'), findsOneWidget);
    expect(find.text('Slot Availability'), findsOneWidget);
    expect(find.text('Upload Slots Per Torrent'), findsNWidgets(2));
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Upload Slots Global'), findsNWidgets(2));
    expect(find.text('10'), findsOneWidget);
    expect(find.text('Download Slots Per Torrent'), findsNWidgets(2));
    expect(find.text('7'), findsOneWidget);
    expect(find.text('Download Slots Global'), findsNWidgets(2));
    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('Check Connectivity Section', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Bandwidth'), findsOneWidget);
    await tester.tap(find.text('Bandwidth'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Connectivity'));
    await tester.tap(find.text('Connectivity'));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('Connectivity Expansion Card')), findsOneWidget);
    expect(
        find.byKey(Key('Connectivity option display column')), findsOneWidget);
    expect(find.byType(SettingsTextField), findsNWidgets(8));
    expect(find.byType(CheckboxListTile), findsNWidgets(4));
    expect(find.text('Incoming Connections'), findsOneWidget);
    expect(find.text('Port Range'), findsNWidgets(2));
    expect(find.text('test networkPortRange'), findsOneWidget);
    expect(find.text('Randomize Port'), findsOneWidget);
    expect(
      tester
          .widget<CheckboxListTile>(find.byKey(Key('Checkbox Randomize Port')))
          .value,
      true,
    );
    expect(find.text('Open Port'), findsOneWidget);
    expect(
      tester
          .widget<CheckboxListTile>(find.byKey(Key('Checkbox Open Port')))
          .value,
      true,
    );
    expect(find.text('Maximum HTTP Connections'), findsNWidgets(2));
    expect(find.text('500'), findsOneWidget);
    expect(find.text('Decentralized Peer Discovery'), findsOneWidget);
    expect(find.text('DHT Port'), findsNWidgets(2));
    expect(find.text('8080'), findsOneWidget);
    expect(find.text('Enable DHT'), findsOneWidget);
    expect(
      tester
          .widget<CheckboxListTile>(find.byKey(Key('Checkbox Enable DHT')))
          .value,
      true,
    );
    expect(find.text('Enable Peer Exchange'), findsOneWidget);
    expect(
      tester
          .widget<CheckboxListTile>(
              find.byKey(Key('Checkbox Enable Peer Exchange')))
          .value,
      false,
    );
    expect(find.text('Peers'), findsOneWidget);
    expect(find.text('Minimum Peers'), findsNWidgets(2));
    expect(find.text('15'), findsOneWidget);
    expect(find.text('Maximum Peers'), findsNWidgets(2));
    expect(find.text('50'), findsOneWidget);
    expect(find.text('Minimum Peers Seeding'), findsNWidgets(2));
    expect(find.text('20'), findsOneWidget);
    expect(find.text('Maximum Peers Seeding'), findsNWidgets(2));
    expect(find.text('100'), findsOneWidget);
    expect(find.text('Peers Desired'), findsNWidgets(2));
    expect(find.text('10'), findsOneWidget);
  });

  testWidgets('Check Resource Section', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Bandwidth'), findsOneWidget);
    await tester.tap(find.text('Bandwidth'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Resources'));
    await tester.tap(find.text('Resources'));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('Resources Expansion Card')), findsOneWidget);
    expect(find.byKey(Key('Resources options display column')), findsOneWidget);
    expect(find.byType(SettingsTextField), findsNWidgets(3));
    expect(find.byType(CheckboxListTile), findsOneWidget);
    expect(find.text('Disk'), findsOneWidget);
    expect(find.text('Default Download Directory'), findsNWidgets(2));
    expect(find.text('test directory'), findsOneWidget);
    expect(find.text('Maximum Open Files'), findsNWidgets(2));
    expect(find.text('100'), findsOneWidget);
    expect(find.text('Verify Hash'), findsOneWidget);
    expect(
      tester
          .widget<CheckboxListTile>(find.byKey(Key('Verify Hash checkbox')))
          .value,
      false,
    );
    expect(find.text('Memory'), findsOneWidget);
    expect(find.text('Max Memory Usage (MB)'), findsNWidgets(2));
    expect(find.text('512'), findsOneWidget);
  });

  testWidgets('Check Speed Limit Section', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Bandwidth'), findsOneWidget);
    await tester.tap(find.text('Bandwidth'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Speed Limit'));
    await tester.tap(find.text('Speed Limit'));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('Speed Limit Expansion Card')), findsOneWidget);
    expect(find.byKey(Key('Speed Limit options column')), findsOneWidget);
    expect(find.byKey(Key('Download Speed Dropdown')), findsOneWidget);
    expect(find.byKey(Key('Upload Speed Dropdown')), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
    expect(find.text('1 kB/s'), findsOneWidget);
    expect(find.text('Upload'), findsOneWidget);
    expect(find.text('Unlimited'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Set'), findsOneWidget);
  });

  testWidgets('Check Authentication Section', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Bandwidth'), findsOneWidget);
    await tester.tap(find.text('Bandwidth'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Authentication'));
    await tester.tap(find.text('Authentication'));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('Authentication Expansion Card')), findsOneWidget);
    expect(find.byKey(Key('Authentication option display column')),
        findsOneWidget);
    expect(find.text('User Accounts'), findsOneWidget);
    expect(find.text('test username 1'), findsOneWidget);
    expect(find.text('Current User'), findsOneWidget);
    expect(find.text('test username 2'), findsOneWidget);
    expect(find.byIcon(Icons.security), findsOneWidget);
    expect(find.text('Add User'), findsOneWidget);
    expect(find.byType(SettingsTextField), findsNWidgets(3));
    expect(find.byType(CheckboxListTile), findsNWidgets(3));
    expect(find.text('Username'), findsNWidgets(2));
    expect(find.text('Password'), findsNWidgets(2));
    expect(find.text('Is Admin'), findsOneWidget);
    expect(
      tester
          .widget<CheckboxListTile>(find.byKey(Key('Is Admin checkbox')))
          .value,
      false,
    );
    await tester.drag(find.text('Add User'), Offset(0.0, -600.0));
    await tester.pumpAndSettle();

    // For client rTorrent select
    expect(find.text('rTorrent'), findsOneWidget);
    await tester.tap(find.text('rTorrent'));
    await tester.pumpAndSettle();
    expect(find.text('qBittorrent'), findsOneWidget);
    expect(find.text('Transmission'), findsOneWidget);
    await tester.tap(find.text('rTorrent').last);
    await tester.pumpAndSettle();
    expect(find.text('Socket'), findsOneWidget);
    expect(
      tester.widget<CheckboxListTile>(find.byKey(Key('Socket checkbox'))).value,
      true,
    );
    expect(find.text('TCP'), findsOneWidget);
    expect(
      tester.widget<CheckboxListTile>(find.byKey(Key('TCP checkbox'))).value,
      false,
    );
    expect(find.text('Path'), findsOneWidget);
    expect(find.text('eg. ~/.local/share/rtorrent'), findsOneWidget);

    // For client qBittorrent select
    await tester.tap(find.text('rTorrent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('qBittorrent'));
    await tester.pumpAndSettle();
    expect(find.text('Username'), findsNWidgets(3));
    expect(find.text('Client Username'), findsOneWidget);
    expect(find.text('Password'), findsNWidgets(3));
    expect(find.text('Client Password'), findsOneWidget);
    expect(find.text('URL'), findsOneWidget);
    expect(find.text('eg. http://localhost:8080'), findsOneWidget);

    // For client Transmission select
    await tester.tap(find.text('qBittorrent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transmission'));
    await tester.pumpAndSettle();
    expect(find.text('Username'), findsNWidgets(3));
    expect(find.text('Client Username'), findsOneWidget);
    expect(find.text('Password'), findsNWidgets(3));
    expect(find.text('Client Password'), findsOneWidget);
    expect(find.text('URL'), findsOneWidget);
    expect(find.text('eg. http://localhost:9091/transmission/rpc'),
        findsOneWidget);

    expect(find.widgetWithText(ElevatedButton, 'Add'), findsOneWidget);
  });
}
