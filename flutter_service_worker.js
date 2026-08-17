'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "4978339b7f30800459775f18697de1fc",
"version.json": "797e31383cd3b8236a7a4d92c64ee20a",
"index.html": "5493ea5761d45adae933990402364b90",
"/": "5493ea5761d45adae933990402364b90",
"main.dart.js": "27e3c5fc5f6c499c3cb92c6c3539a7d2",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "f283ac45153326f1aea45b1a8c440a53",
"assets/AssetManifest.json": "d25aae966812b48f2df0f31faa814eef",
"assets/NOTICES": "15cb64949f0946e9ae89ecae3c00e203",
"assets/FontManifest.json": "b633e2b51be97533787ba16d93269ba1",
"assets/AssetManifest.bin.json": "4fd2404fb94d8e8686260d1de8764027",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "cd74da9a120c85d851062be9dee9836c",
"assets/packages/flutter_3d_controller/assets/model_viewer.min.js": "11f3833db561a92ac9100cd43d28899b",
"assets/packages/flutter_3d_controller/assets/model_viewer_template.html": "d370dc1bc2b1dd29090c1946dbef646a",
"assets/packages/flutter_inappwebview_web/assets/web/web_support.js": "509ae636cfdd93e49b5a6eaf0f06d79f",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css": "5a8d0222407e388155d7d1395a75d5b9",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html": "16911fcc170c8af1c5457940bd0bf055",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "234af91769326bc8ea8176ef2ca416ab",
"assets/fonts/MaterialIcons-Regular.otf": "eb37f8d6d52d3167b84588b7cf3157ca",
"assets/assets/svg/deco_bedtime_dots.svg": "cded0c3f322e0f3d5763ac6783a6e280",
"assets/assets/svg/reminder_decoration_bedtime.svg": "e5454c98b2191a43afa0fe1862025fcd",
"assets/assets/svg/reminder_decoration.svg": "149d8ef8678ee42ad3d6635406784c55",
"assets/assets/svg/deco_evening_frame.svg": "a42315a1b735db55bb932e2c3b64ae76",
"assets/assets/svg/meal_stars_evening.svg": "00ebafaf2c6cf29583f2b309910a5121",
"assets/assets/svg/icon_done_check.svg": "99255c8628dfed2d98520d5138d41bde",
"assets/assets/svg/deco_evening_frame1.svg": "c9e992913c8015835bf6d4e7538ce24e",
"assets/assets/svg/icon_clock_soon.svg": "c155362fe226f7674e5dfc28f06bd00a",
"assets/assets/svg/deco_day_rainbow.svg": "f02fc46ee181d56f01e0ba751546d5f2",
"assets/assets/svg/decorative_elements.svg": "c3bd595999a5e52f2920c9dcccabfd96",
"assets/assets/svg/icon_file_dock.svg": "f78c708ef3b1eaaa953e90301e091545",
"assets/assets/svg/deco_day_ellipse.svg": "120103abd9a90a9735e2b6b398b98927",
"assets/assets/svg/icon_clock_future.svg": "2651efc7902e0ef37b3003a23e85c9dd",
"assets/assets/svg/meal_moon_crescent.svg": "14d3a6d4fbd2c3b8024f9a384a77cf4d",
"assets/assets/svg/icon_shield_track.svg": "f2648d76c6df8aa550bd9a6671f9485e",
"assets/assets/svg/icon_pending_sun.svg": "1b73e158e9ca77f8e41bd72390277317",
"assets/assets/svg/icon_clock_small.svg": "277bb17b260b5ef757528270c4b50407",
"assets/assets/svg/icon_calendar.svg": "870d4ab91bb34002b0c555615d4719c0",
"assets/assets/svg/icon_check_done.svg": "f43c3506c37c67e9a92c30cd095cfcd7",
"assets/assets/svg/icon_dots_circle.svg": "702ed84860850570c3ef030f593be60d",
"assets/assets/svg/reminder_decoration_evening.svg": "c49ff9e7e77e90af504d3bba51056e1a",
"assets/assets/svg/deco_evening_ellipse.svg": "20b312628c123fd21a81c48a8319b42c",
"assets/assets/svg/deco_bedtime_moon.svg": "17f74188d216fde1848e3b23feafa6f2",
"assets/assets/svg/reminder_decoration_noon.svg": "1c631bc3e6b547f729244f2c23339eca",
"assets/assets/svg/deco_bedtime_ellipse.svg": "41f6dfe001a24d83fc862c57ef8ece97",
"assets/assets/svg/ellipse7.svg": "3ffb8b96c25f33390d1a9ccea127eb95",
"assets/assets/svg/meal_stars_bedtime.svg": "64b70523623d6861bfd7a458e23c2ce1",
"assets/assets/claim-reward.png": "aa78efc67edc8fd3be87900de081c566",
"assets/assets/watch.png": "2cf5d9aecd99d52ba1ef3d9ed20d18b0",
"assets/assets/sky5.webp": "b924cd1437ba1ff94c5abe323a4f3ac1",
"assets/assets/3d/README.md": "99b9c9468d4332a4a1fb534177922126",
"assets/assets/fam.png": "db5038fd1ba909efa71cbe6f17f4d84f",
"assets/assets/taichi.png": "39907bb7b79af0fb24d0bc5114c5382e",
"assets/assets/loginimage.png": "38dcba98d268c95de410fbde72812679",
"assets/assets/logoMyAtlascare.png": "5d6482939d35fdb00cec4d2f5821a4c3",
"assets/assets/header-bg.webp": "03560c8308f78ddc4dc789b8095d47fa",
"assets/assets/sky4.webp": "6135645bf62ca552886e425a3595bb54",
"assets/assets/bms-icon%25201.png": "7bc4db84165dc63ecab1c488b6c3db23",
"assets/assets/Hospital%25203d.png": "81ccacf1aec65e9c54708e3abf771c8e",
"assets/assets/banner.png": "e9126410930b85283a872766131dc2b4",
"assets/assets/images/vital_temperature.png": "659a090b1cc2d9bbed4e914da3c9f16b",
"assets/assets/images/vital_bmi.png": "610320aece341d9aa93c8b26cd8f3c9c",
"assets/assets/images/spo2_hero_anim.gif": "29028ead3729a81796a7fb840fe7059a",
"assets/assets/images/vital_heart.png": "4368fdda2931caf9f033ba9afe40a07d",
"assets/assets/images/temp_hero_anim.gif": "a4ef59274885c2a86283f3c7016a6c83",
"assets/assets/images/meal_basil_chicken.png": "df3bbbd5982eb03336f2b1467b31d021",
"assets/assets/images/vital_cgm.png": "b389612f5c55b5b9faa161e28aef98af",
"assets/assets/images/sparkle.svg": "cd0fa82b4d8ef3906618580456e759fa",
"assets/assets/images/vital_decor.png": "ea230360200d707262919ca9429bb05f",
"assets/assets/images/allergy/penicillin.png": "8f1a21f949d26a9e1152574c04a45b0b",
"assets/assets/images/allergy/shrimp.png": "6469f3ce521853fe2eb83aa1395dd178",
"assets/assets/images/allergy/milk.png": "31986d3416491302129a3b1ffc9b0f8c",
"assets/assets/images/allergy/ibuprofen.png": "e5c5ccd9de1d79c5d8443d8daae540aa",
"assets/assets/images/allergy/aspirin.png": "aee35a7d1f8f40234f1dff18c69e9145",
"assets/assets/images/allergy/peanut.png": "85eaa1c8c8479f77b4a25e6789e492f6",
"assets/assets/images/waist_hero_anim.gif": "ff0517e8a7734d90acc41cc2bf704aef",
"assets/assets/images/family/me.png": "4ca813a02484cea23671b13baa19fbed",
"assets/assets/images/family/preecha.png": "e00a42fd0019fb3549d3c1e4ddb66bf2",
"assets/assets/images/family/fam_jane.png": "b51b17deb7b225b4acd2589547866c95",
"assets/assets/images/family/pat.png": "569e8c87c18259d3328a61c1b16f5028",
"assets/assets/images/family/mintra.png": "27b23e3b01ee1006cebf28a18053ce67",
"assets/assets/images/family/jaidee.png": "5fde542ea9fa4401544b77f92658b873",
"assets/assets/images/family/fam_mae.png": "a2f8f8be9633fc0860ec4ae454ac07a0",
"assets/assets/images/family/my_qr.png": "8e2a1c5b7262cd4f36fb3cbcd721fe33",
"assets/assets/images/family/bangkok_map.png": "5cf849f2320c0c9a9bb3123b91d04f19",
"assets/assets/images/family/fam_yai.png": "7ddbf91fab15a7faa69cf3a2e6242cc2",
"assets/assets/images/family/somchai.png": "5d763feeaa19048c52a030f48f7a679c",
"assets/assets/images/family/somsri.png": "fc0b86390cbd2127d595f458a60208d1",
"assets/assets/images/vital_spo2.png": "e684fdb1ade924b392cbb1ef0e1d78a3",
"assets/assets/images/stat_salad.png": "dd5a4c5bc3cf3cf8f10eafeb81bcef75",
"assets/assets/images/medicine.png": "b2279cf612bad7bbd770967921319bc8",
"assets/assets/images/salad_bowl.png": "2716bdb2894bbe294c71615e88ec0924",
"assets/assets/images/assessment/inhomesss.png": "03bb9629610911914160bc7ca72cf359",
"assets/assets/images/assessment/diabetes-risk.png": "ffd0ec9427883327a9b4135270cca861",
"assets/assets/images/assessment/dyspnea.png": "db90140e7f4ef76aa850a7b22436758f",
"assets/assets/images/assessment/mental.png": "10bd163303a06e503b27345f251f6ddb",
"assets/assets/images/assessment/bp-risk.png": "f9b92e4516589218de0286a5581836f3",
"assets/assets/images/assessment/crisis.png": "da21689c3c3130a5e97ed7a4dc8d9600",
"assets/assets/images/assessment/cv-risk.png": "ebdab1587ded9afb48c9fe56013e836e",
"assets/assets/images/assessment/esas.png": "1445dd739f8c03dfd1f31ec036a523fe",
"assets/assets/images/assessment/palliative.png": "5f782eb4772bcb01df6f6d2559914e1b",
"assets/assets/images/assessment/asthma.png": "f8c6468c00b56f6f090b97d29274b8e9",
"assets/assets/images/assessment/screen-35.png": "5f00c4a8b3253ff402caff516e6fb2e0",
"assets/assets/images/assessment/adl.png": "07605f3dfae158e2b0b5417604224155",
"assets/assets/images/assessment/barthel.png": "227f6e7126dd01d87374658d275ca39a",
"assets/assets/images/bmi_hero_anim.gif": "5f6158f87f3d94dcd15e4fbcaf860a86",
"assets/assets/images/heart_rate_hero_anim.gif": "547b80891c2d781766a62e7844ae13f1",
"assets/assets/images/vital_heartrate.png": "27d7996cf0c5adfc734c13ecb5bd7ffe",
"assets/assets/images/vital_bloodsugar.png": "6f2a99fae7c2fef066543435fc0568df",
"assets/assets/images/bp_heart_anim.gif": "5f60d2a8ada368e3f6f5e8647e15b422",
"assets/assets/images/me/about_hero.png": "1d01ef448dc5753cd9b6862b2c948ee7",
"assets/assets/images/me/health_id.png": "37b91e153c87b85397979b12bbed88cd",
"assets/assets/images/me/about_halo.svg": "35ec99c0b403c3dbe77996f4cc1a0dd1",
"assets/assets/images/me/apple.png": "16e283042eee79c598fe27e0f897df50",
"assets/assets/images/me/syringe.svg": "f6479cd6598da45676f36d117648c4b7",
"assets/assets/images/me/insurance_sso.png": "5bad7e76bf07b4ed74c4187823ce362f",
"assets/assets/images/me/insurance_axa.png": "bf47c32e8367dd9627750b3ccf729a12",
"assets/assets/images/me/insurance_goldcard.png": "fe23fffe507f82e97698fd432ee8867f",
"assets/assets/images/me/google.png": "d89eae38367271f22b7f62a9b258e56f",
"assets/assets/images/me/facebook.png": "6e12fd81bdc45ec1f6a7307930c69b20",
"assets/assets/images/stat_kcal.png": "06474221745cb7a01af37a49218eccf1",
"assets/assets/images/bg_hero_anim.gif": "791f07fcc671e566e5304f1f937d3b5b",
"assets/assets/images/salad.png": "5da9663facc399699c4bfca040feb19b",
"assets/assets/images/vital_waist.png": "44558ea67b07024fef3d2f61b29cc31d",
"assets/assets/images/pill_bottle.png": "136e4c59c7a8fcb4eb543704c867183a",
"assets/assets/images/meal_pork_congee.png": "14ac020ad0c53d57c6766deff52f4f9b",
"assets/assets/sky3.webp": "b9e3e2cb96acc2b41cafbb05957cb547",
"assets/assets/Aerobic1.png": "6d2fa3a22e11ffc7f96214c5f02f07ab",
"assets/assets/get-reward.png": "53e49ff7d9f6f4a53ac4385a9eb6e7bc",
"assets/assets/Aerobic2.png": "168656cc81eb79ad844011a46ede1003",
"assets/assets/AiBOT.png": "4ea8d07dcaba3c32a01a5fca3217236b",
"assets/assets/default-reward.png": "8b74ed6495c0b349c4f447192815eb30",
"assets/assets/AiBOT2.png": "a8a99d4f31718f19c259c10ea3cbb37e",
"assets/assets/hand.png": "dfb31709a24a2c7a98ad9f38475a151d",
"assets/assets/sky2.webp": "e82d5fa08745a0e55c892919d5b8068b",
"assets/assets/Appname.png": "84e95c86212235244481946a1fb5f709",
"assets/assets/bgsky.png": "24be88e66668879b530a4c0fa1844e38",
"assets/assets/logo_bmsgroup.svg": "0b53a7fa2e885f48baea74fa7e6cf4dd",
"assets/assets/apple.png": "095d8a25bfea5781d05d433d7bc654df",
"assets/assets/sky1.webp": "0e1a382b434ace523d701825958a38f4",
"assets/assets/appt_scene.png": "a9b3ffcde32c4cb9f5e5e151c145411f",
"assets/assets/startaerobic.png": "99429980df8a5899fc0e646b568a2800",
"assets/assets/doctormuscott.png": "6824d82449b9cf4afbef0cc4766076b9",
"assets/assets/header-bg.png": "fa3c5904d832856f641fe00d3c97e865",
"assets/assets/vital.png": "3b1f04d02d98397bb87904596793eccc",
"assets/assets/Pill.png": "6c121ad80abe64de3f757436923cabf7",
"assets/assets/med.png": "b521ede9e64b4eb2b93f6dfff656e859",
"assets/assets/rest.png": "4b4690faa62492d9f9ea235f9fc16e6c",
"assets/assets/volunteer%25203d.png": "783197ba0eef7499a0c504cd68a35885",
"assets/assets/line.png": "b0886ec862a127f5238212c4c1eea61a",
"assets/assets/fonts/notosansthai/NotoSansThai-Variable.ttf": "bf70020c73d6064f11cee708fd71b60a",
"assets/assets/fonts/sarabun/Sarabun-Regular.ttf": "943f4762fbba430e32573418aedbfe9a",
"assets/assets/fonts/sarabun/Sarabun-Bold.ttf": "69b0b84bbe657fa10f4b324b93f5f62b",
"assets/assets/fonts/sarabun/Sarabun-SemiBold.ttf": "3877ab44e38cc41946013bf47dba08e9",
"assets/assets/fonts/sarabun/Sarabun-Medium.ttf": "46095e37cda01da34d829acffc7b81f0",
"assets/assets/fonts/sarabun/Sarabun-Light.ttf": "c80028171f09c7b2fab738a89c28bac6",
"assets/assets/fonts/GoogleSans-Italic-Variable.ttf": "8db7113e37a6cb5ab1d6ca620dd7081d",
"assets/assets/fonts/sukhumvit/SukhumvitSet-Light.ttf": "1c2625bbb3f5af12c941c712183f9708",
"assets/assets/fonts/sukhumvit/SukhumvitSet-Bold.ttf": "cf83ce0aa5e75930d38e0bff88d9426c",
"assets/assets/fonts/sukhumvit/SukhumvitSet-Thin.ttf": "e80083d09b84fbd00e556151e4118c62",
"assets/assets/fonts/sukhumvit/SukhumvitSet-Text.ttf": "69fc4f0f2a8869feeec71379c2cf824c",
"assets/assets/fonts/sukhumvit/SukhumvitSet-Medium.ttf": "e54f4b9d0df88a9af7636bee55ac9bc1",
"assets/assets/fonts/sukhumvit/SukhumvitSet-SemiBold.ttf": "d55ff127a3c864c5d185b86c3d28f0e9",
"assets/assets/fonts/nunito/NunitoNum.ttf": "df5ef0a2256e903bc06d422adaa273d2",
"assets/assets/fonts/GoogleSans-Variable.ttf": "c98a147e31d33b276dbfced370e1348d",
"assets/assets/fonts/ibmplex/IBMPlexSansThaiLooped-Thin.ttf": "39ab679ca117f9fa1f2345464ba81dbe",
"assets/assets/fonts/ibmplex/IBMPlexSansThaiLooped-Medium.ttf": "01ba42e8f790928ac0319d2fc13e60dd",
"assets/assets/fonts/ibmplex/IBMPlexSansThaiLooped-Bold.ttf": "793c36ae24f00250b7990f21f8e4610f",
"assets/assets/fonts/ibmplex/IBMPlexSansThaiLooped-SemiBold.ttf": "891785ed0eb68609e3df897745fe3ab6",
"assets/assets/fonts/ibmplex/IBMPlexSansThaiLooped-Regular.ttf": "59a8e564857363ff27a822bf93184fdc",
"assets/assets/fonts/ibmplex/IBMPlexSansThaiLooped-Light.ttf": "9a77a6c0bf82c62e08516b73808cf559",
"assets/assets/fonts/ibmplex/IBMPlexSansThaiLooped-ExtraLight.ttf": "5b2525d1e2d5d1df956d52750c615b85",
"assets/assets/google.png": "506695b89543550eda834cdbaf31ff3b",
"assets/assets/bgappointment.png": "1f6cd2451237af84a755ef917047a11e",
"assets/assets/facebook.png": "672af191f3360f368fae2e4749e61544",
"assets/assets/healthid.png": "4f69f084ec03e7e6693c7e85ceee4584",
"assets/assets/bgvisitappointment.png": "a19164a9ea698a9dfd0941dc1dfa47f4",
"assets/assets/kcal.png": "e457f39734ee586e1e52d1f998b844c5",
"assets/assets/logobms.png": "51c15574b176362b1642154e0f4f8693",
"assets/assets/bgpacket.png": "a6ab6c1297a2a36a75f774d201ddd3cc",
"assets/assets/header-bg-sky.png": "489ad6b182a22758fd4bffe6ddb86024",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
