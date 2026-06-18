'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "5a6c67e4df75f48fa3ad570a4242d90a",
"version.json": "797e31383cd3b8236a7a4d92c64ee20a",
"index.html": "5493ea5761d45adae933990402364b90",
"/": "5493ea5761d45adae933990402364b90",
"main.dart.js": "bf36285054238f3742dd01efde7e745e",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "f283ac45153326f1aea45b1a8c440a53",
".git/config": "38881ccff4dc4e249623736f3cd97a15",
".git/objects/61/120644775281f3ff77bb55aeb6f67fb924030a": "ac6e22d1edf5637c1ba51804d5ba1f04",
".git/objects/59/553237d920b68569edbc5a419ea5cbc5828b63": "757c303bee589713a681426c10c95fc1",
".git/objects/66/01aabd3374a24327c2df766d0bd8351a2cebb2": "d8b6555d954dfe05b0312feef4ecbc25",
".git/objects/3e/859cb65f1add2ad22bae614a4c357cc2e12dea": "42735f924a666d9b3f01e24742f7e78a",
".git/objects/3e/8e740aaf6ed9e1a34fe9c63a9600f0598dfef4": "ac489b821b5a76ec7e58c6c5a552c5ad",
".git/objects/68/ef2b850df0e6b1bc23597675cd285ee34453e4": "be46d36372e0681ace7f810142c770e5",
".git/objects/03/baaaea25dc067ec437047967bcd8460954e546": "47dba0964edfca390674d44cb351b01f",
".git/objects/9b/3ef5f169177a64f91eafe11e52b58c60db3df2": "91d370e4f73d42e0a622f3e44af9e7b1",
".git/objects/9e/3b4630b3b8461ff43c272714e00bb47942263e": "accf36d08c0545fa02199021e5902d52",
".git/objects/04/bd0a5e760ea88b0bb07b802772a2defcf224cf": "d8062547b9f950d135e689d8c9122746",
".git/objects/69/7612b856b42c7df2f6b11a751697ce3fb59ba5": "eb2c167bd5d2090211aac5d103a33a2d",
".git/objects/51/ac868d2e4ae1bd595259ed84b7b017381d96cb": "ba2f43323ba13940fda45e34aac637b4",
".git/objects/58/94e22af12baf91b9b9cb2e3b517b112781d811": "2d0f92b7556660e1ea78dd97a6f3bb2f",
".git/objects/94/27c1324d5e2a0e936f67fd94b5e584e72411ee": "fb54f649c057a0557814b5735d9c335b",
".git/objects/34/4706b2da40a5f3c5eb5431e721f4c8837794cb": "6408688291696321ae8d02d1cf386a6b",
".git/objects/34/ff285e98b69c0b8b4fda588495d8078402eff5": "401a6359b0105935f3aae79be88e2e0c",
".git/objects/5f/e72480448f82c070d197fc00e054e182ea9298": "2fcccb88e64ef7a7ef0d42ad8be63859",
".git/objects/5f/460fa7aa78083567365eb4171a59806618e1fe": "994271298afae9f6916c63076c0410db",
".git/objects/5f/c5116e6855cd0045ee1a77fdb2e0c6bed88bb8": "07fe0e60a5b0c264926ac2a05fde14f5",
".git/objects/05/e877444f8ae8067d48e5514561618fda811cd4": "480236e751cb516ae4751c22cdffba04",
".git/objects/9c/180e753efcce5ce4a410ee031109ef75065691": "79e7d05f1b9320df7d5aaf3f6e1abc08",
".git/objects/02/02c2cd5e4364831f330c30008141d05e78d783": "5954645e0f09d2142f6e807524f686b3",
".git/objects/a3/92efd7863e8504ae6ea76bfb56564ef6d03cf9": "3f50bf18e05edb38e0f8cbf5aff6f57e",
".git/objects/b2/4c403af200d7def00c1958fcae709f2bbec36e": "03dd4300f83912b00351e12d979640f9",
".git/objects/ad/c0cd578e1b03c6addb893daf9985bbc5670b0f": "3dc01112a20089e52ac17a3db9241f92",
".git/objects/bb/624edad0d6864bac3a374f79686b0b707896cb": "d7c135f9c9238e24a0db85aca3095582",
".git/objects/d0/5668cc95649e7b5230c735912771d640411a9a": "214777b1fb52cd1357f2caf3f900aaae",
".git/objects/be/de6eb062e0f31a0543b1e986bf0a4c1dc5e1a2": "18ffc071126c2322b4bd532880771472",
".git/objects/df/d19d71a66b91a91be98f7ae134cf877f496824": "400b360023b07e6259fefed2b052d61b",
".git/objects/da/0d5aa44a8c93eda469f7a99ed8feac32d5b19d": "25d25e93b491abda0b2b909e7485f4d1",
".git/objects/da/64caf858a9533a2973c5a7f4ece35326559f87": "d1a003ec99623e31d969f637c6252041",
".git/objects/b4/9b7c64c4796ca15b32d07a839574bba8e7e72e": "715ba1516b3bbe98ae810b35063a27de",
".git/objects/a2/90a3dd2bcdc4e5ccb1fb07ebca0bfb7c3f1034": "de8dae5968c332770386c26e7f7dc181",
".git/objects/bd/ead571c3a15dc36c12915478bfebf83062fdc3": "1ef4c60a6ef9ca0556ab509882a50361",
".git/objects/bd/36e58ceb916a4cd6911736a64601967c0b5964": "106826db40ecc0e1fd2b3075d260eec2",
".git/objects/d1/2adb1cd3ce155a603e2aee058fa99ad7c2d4d5": "ed2e6a16ca18696ca4b8a70834556465",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/bc/16c7a4b4002e0e0f954e25ec15c1631d037062": "ec3a532b0fde75af6487da1fd3e543e7",
".git/objects/bc/ce3a92fe1b8a61a403f0124c2ff85bfdee82aa": "161937959c454febb99099e0b2b119c6",
".git/objects/ae/1f705f314ac5767ad8ee166c6adb850c1a8e5f": "26bbebd34b65878c0eda5ef466fd7882",
".git/objects/ae/b8b2b59cfa4bdb0ca98ee0f18f6500b41b203f": "82ecc5430db0c6bf0706ac6ff79dfbc7",
".git/objects/d8/8128adaad90d2fd7cdabe7b36eaaaed0d3a25b": "3d15963af0d77c1cd40702fb7c18fa93",
".git/objects/d8/01a8b8467fc884b861c0e9c30418dfe6191b83": "ae53f9dcb9ab9889adc25e6b8baef075",
".git/objects/e5/ab0b459b25f09b99594925e834de65705ac5e0": "8f210be1c637f1c4ef076f92ab9fdb90",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/eb/a27697ccb094e2c1ab6aee19df99e663ffcc32": "26219fe54865e73b8702aa49215e336d",
".git/objects/eb/f56253ec5ac185909dc5623c33912e2a3dac2b": "cee34d40b73ce8bded387d69bc11730b",
".git/objects/eb/ca7833a3d8bdabf3a620b4cb4a1b507a5e2492": "3152b5995a733666f97fb96fcfcf11ca",
".git/objects/c7/0b100a3e931a84b061489fea2779cfe28d73d3": "d5a961ea0cfdacc644ec611b7760e28e",
".git/objects/fc/6c63a9b4e0cd0b613a78c3f11a5fee6fa8b80f": "02e1bf30d13d9c6af146b920d51a43e2",
".git/objects/fd/50bbe99f779d045ae8b05a663721a7a715e69c": "180107882f83a98819b4f5a16539697e",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f5/90f0b39f6df550d90d12774b290109b0bfabe9": "fa35a66c8140012644d88ce2881aa340",
".git/objects/f5/9f9f998d83239861c4a8382e111037118447a2": "599a6489d42a001b33ad75fa3cc124e8",
".git/objects/f5/d30167868c786d31e1995648019cb345199a4f": "4c7b8ada4b3ae4288ede5cb569338bc3",
".git/objects/e3/893d874f83726c7faee6b44a20e3f501a947cf": "018c2070207c5adf1a0677acd0bd09fc",
".git/objects/ca/f3c835cad6a0a08d874ba65fcb91aa83ae051f": "411d9eec636696eea85394c8a8616a45",
".git/objects/ca/3bba02c77c467ef18cffe2d4c857e003ad6d5d": "316e3d817e75cf7b1fd9b0226c088a43",
".git/objects/fe/3b987e61ed346808d9aa023ce3073530ad7426": "dc7db10bf25046b27091222383ede515",
".git/objects/c8/4199c34fd553ed3a16208b2ff53ecbfb52bd6b": "c5a0f8e057235711bf8a21c53f5d152f",
".git/objects/ed/b55d4deb8363b6afa65df71d1f9fd8c7787f22": "886ebb77561ff26a755e09883903891d",
".git/objects/ed/67e06bda0a2345555ccffe713edf1187b8e39f": "0d70800bad7e3d621caa7b28ff3ebd63",
".git/objects/ed/ec3be19a7eda11fada77b57548d6fd7ae91958": "49d1f25877410a6be0354489e31db820",
".git/objects/ec/bc349aceb0ebd844472e9cd96829ef1a616db5": "1b884fb8ca33f329250c81487fa83f0e",
".git/objects/4e/34adc374b9a1ae44e51d60be987c5aaa1569e3": "7f65112abe29654f8a87952e5b76049d",
".git/objects/20/3a3ff5cc524ede7e585dff54454bd63a1b0f36": "4b23a88a964550066839c18c1b5c461e",
".git/objects/29/0e95cadbc55d23b52f5456c3098987c57179bd": "754eb3bf780206e28cea1beddf1b4f80",
".git/objects/29/f22f56f0c9903bf90b2a78ef505b36d89a9725": "e85914d97d264694217ae7558d414e81",
".git/objects/7c/800ebba171e62bbed02040eeb2c9936760b829": "f35a184ea3b1d84f2bf994e2768b916b",
".git/objects/42/a668677fbfd17e627950964e3ccee36ef3b392": "d19efd8a8cdcc2d8f8636b129fe57eb2",
".git/objects/73/cc33eb83131f4805ca8749778960e13734f62a": "a601d551a4e25cc10f966b4586e59cce",
".git/objects/87/d1195c19e5821bca7a52ffc9eb749fa7870c0c": "2d5e5a7f654b230253dae29d35dd240c",
".git/objects/74/dee6223ab1ff875e0be12ddf5cc4aecf9adfc5": "aaa052f3bafb15fffede7406734fdc0a",
".git/objects/74/c1180dcc705703d23903f6b3397ec96899c758": "3b5b70d2d7a61cbb27aaf3a367634554",
".git/objects/1a/5ac61b6fa6b641d0ab1e58dbb750588e22ef2f": "ee88d1c2a53569e7aef21fa663ed0f23",
".git/objects/17/58ba01b48071715a6b7320d1350deb25210f0d": "b0a3e63f471e0ccbfc27ded0a08006eb",
".git/objects/17/d75b20292b2c0411192fd5d16ece6eff17524c": "d85d86e61a3c64f74a6561e43176f883",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/10/72c440cfb6b76fa0961e77d6304670079dc898": "34521be4fda076e64462edd560daeea9",
".git/objects/10/9e09162ca13a58688826bdba02799a2807377e": "1cbece680724604d8d9a5827bdb62a2d",
".git/objects/4c/b7bf602d5e77d81eb1a90534b4be9a64768ab7": "19157850f8a9eedb5edb1ae032b60af5",
".git/objects/4c/ed648ce26702c02ed64a762d85b577a57c25df": "6057c85c7d5254029adde79ead423b00",
".git/objects/4d/bf9da7bcce5387354fe394985b98ebae39df43": "534c022f4a0845274cbd61ff6c9c9c33",
".git/objects/4d/43da7cb374b0633ff08adc7a2cd6248306bf33": "cc1546774043db01e444d6e055a6c90c",
".git/objects/75/42c6b0e9cdcf9c8e3f7da12ab5edf7415f9fad": "f31e0e5a82c78b71792ba19b15f96867",
".git/objects/86/edca6bea04ca1e2d8ee8cec658123506ea5e5c": "3a6a70c500233aaa861fd27c81415903",
".git/objects/72/80bdddbc17dfe709057953d0753e5ffd0f0f2e": "ba56b40d645a0f16807ab3de83ab0ea1",
".git/objects/2f/db011c520936e3831749d5eacd7260007afba1": "86f8483637e08afdca98b62227ba90c9",
".git/objects/43/182cb27364daf9cdfc59c9921f88d5a23c650f": "b357632b4503d33080bbcecccf839778",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/88/9a0343a9daa9c4e82adcf115bbba282792baf9": "b3bb40085aafbb074e35fb65a1257b96",
".git/objects/9f/21eb7f0b4dfbbc6c0709551a233f1ac08376ec": "4d28d9d32a1a14d208bca9dce70eb25a",
".git/objects/9a/963d9cadbc98139e7d8b7299f7239bf5516dee": "a34aa68e6100f5bfa9d3de176b99d7e5",
".git/objects/5c/a017893b2927c9a549a678278c883a97ef2a0d": "ae6097befff3fad1d76396cd065264d6",
".git/objects/5d/9102f85668b239e6bbc42ebe77f54069541abf": "a912a11a3dc52860783d1704df9029ec",
".git/objects/91/8e3b2083e4a6f4357391f1d5b75e0ec788096a": "e32fd803f57eacc295d5ab0c9b77e401",
".git/objects/91/d9f6edde00d9d663899f0282f45a18606068be": "31a966b21f1bd15db6b7bf943b38de4c",
".git/objects/65/7301b769913d1947cc3bf3725339133aea74be": "b4409379feef8149e92fc95735ce8df9",
".git/objects/98/0d49437042d93ffa850a60d02cef584a35a85c": "8e18e4c1b6c83800103ff097cc222444",
".git/objects/37/1279dab6903a0677c38ceeedbfa2b07031c3e7": "71fb09088df0696fd4015417939d5e81",
".git/objects/08/0c67b5f80bfdf0d67ae30ccca3114db1498688": "0882b77a587b15cfb8a0830479cee6e4",
".git/objects/6d/6f9ebd9721f88e6e3d16fac050884572d6fd9f": "4e0f0f1bd46655f911394f6ef6cc63b4",
".git/objects/06/7f2f23c1c749bb68a89cee0e84b00594e17af6": "a5e4e21333028104c9a2216a7d38a9ac",
".git/objects/39/57e916f02a906dac0a005c0758b81a8f4a76a7": "bc20a119918c705a3c2460f7a702216c",
".git/objects/39/8ade9a4520ad910c70b8610f967e3dc19bb6ff": "ad967697fceaa90cd5f6e9512cefed22",
".git/objects/99/a45fc1842431e02c3a08ec83d0e74826992ea3": "64dc97586c69a27f350a038c9bd0a86e",
".git/objects/97/ba81950905e3176cd1497b2533218d493b3aae": "af12fd0f9c5a3c25c368e4bff1686d1c",
".git/objects/0f/de1282d980b7216bc7b5f0dd55323537e20d7b": "7f8086f89eceab522a9f0d0f7f76d2f7",
".git/objects/0a/3693c7429f74900ef309b525691e1e8a3263bd": "1818500a4b325ab2b6e2fb4ae10c8c0a",
".git/objects/0a/e0c386dad9694eb3f2c296ce55b4507c692dc7": "b6660aef0bab4644ea60a1eac6ff7bc0",
".git/objects/64/d0a37defae1e98ea4fb0b6ed9c721a98f8a863": "954bb006a243de5711ec5d86ecd3ca50",
".git/objects/90/fa77ccaf0538b0c824bba6c2e08b26855c267f": "dd79410639b8eee937ebaaac838b4825",
".git/objects/bf/89fa16b4e9d9bc1e410de37d5c4ccbb709885b": "c89f3fb18fca63ff60a6b142782e4201",
".git/objects/bf/364612ab2b1656210e88bfabb3811c1645f0b8": "cee8b7c05035014970eb540569cdeb88",
".git/objects/bf/60c390a74a855b61798cd917bcbc81777dc679": "89eb01429d42927bbb02b57c87f7a73a",
".git/objects/d3/b3199faafd7bdfae2a07ed4428a90dcd472d67": "f0f77b7e3f603178500f39fd7fde8d16",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/a7/463c0b3675e7376d09d5d26b772a131c4f3cbc": "d1ab46d0de234d1bae36b6a749858358",
".git/objects/a7/f3be1f19793c062e78f66155e5988ae73879ab": "b21f03f84789b51fbf90e823b333194f",
".git/objects/b8/f36bfb9b268210a49e77143e9bf4129cdae698": "b1af1e3ad8692b7e3e12e92c077204b6",
".git/objects/b1/2dfc7e31599f88a2825efe881c98f1d1d081e7": "636a6e014843a8111b9c1c17a8de7449",
".git/objects/b6/b8806f5f9d33389d53c2868e6ea1aca7445229": "b14016efdbcda10804235f3a45562bbf",
".git/objects/b6/aedd5cc51b809e6fefcec7d14940539a23cb16": "d15044fdb4a523e566ec819c55cd0c90",
".git/objects/af/07b8e365517bf490524c8a2f9f7745c868676c": "d052b2945ab29173b3430fcbfbeba0a8",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/a1/cca78bdc25810bbc527dccac86d1f6849b3ba0": "c16f9a4bad08022cb575206805484e3d",
".git/objects/c3/630d85e7e643ae6c6778df7510eafdfa6c2c33": "4d4eae001ef4ef49741fed71f2364f44",
".git/objects/c3/2960c8832e3cfc6b3f5277fb73aa19b83bbd56": "6e7e577bd38c61c6e64d3f76165b7f4b",
".git/objects/c3/64a022dd1a6f2c0eaba6cb3bbd7b48e78cce4f": "7815fc90cc33c8d26c8c9e2f250cb618",
".git/objects/c4/31ddf0afa6b97834a9951c9609d9d4622fb425": "01363bfbd391e12537d8c437c99d6231",
".git/objects/c4/016f7d68c0d70816a0c784867168ffa8f419e1": "fdf8b8a8484741e7a3a558ed9d22f21d",
".git/objects/ea/77c0042513024fd3d661ef607f310330b123c6": "20d92ac992d939e9e779ebda6ebc10b9",
".git/objects/cc/df9156b90d2101565373bba8514d2b3d40a9a8": "7b3ee9173a8b2f0593f76f35ba51ac6c",
".git/objects/f9/e1bf61f0834a430af64a3af7fd42bcd7daf695": "e24fff720114c8c880cbdf0f9c363c81",
".git/objects/f0/ac681e7079493620ac1f962bb3813feec54a9b": "2ca63496bfbe13ea5e66f713a6a5dae0",
".git/objects/f7/8be2b086b585c17753b29fdbc2caa55b00295d": "4ef22e09803a165857cafa3f66e2caee",
".git/objects/f7/1e08ddffe8f0caecb95d49b5d089009d7aa270": "2538f90b24de66ce3dd4b3dc1536228c",
".git/objects/ff/346b4d2f5edbae202760066b29a52f89767922": "3a38e8909b64a7a142218694fd96e691",
".git/objects/c2/663768f149a5bc5a9fab0674fa3cf5e894511f": "d38198947cd5a8cf33aaf324cecbf4b9",
".git/objects/f6/82fcb3b99d7bc63fe318dda803cd2624d053f8": "a2d02b63567b558f2de635373fa12690",
".git/objects/f6/cd77605fd7e4bd18ac47de03d8a1becb9d6ffa": "3bd25cb3dbffc7d53de8843b5d46a1e4",
".git/objects/e9/01279a13bb0d16fc0dc6d24f06203a1a1bd787": "9ae05f57504f848ad60d6e64daefc534",
".git/objects/e9/1db7fe61df88f5392d0201c7587613c41b4f38": "545f4c4b6dd139eda6524b7151c2b1ce",
".git/objects/cb/40a63f2ad5b8cbf584182d2a8eeffbcc1e6f14": "a862c88f21c81499e178f0442e3760e1",
".git/objects/cb/c7f7fb0de8448c336944ff84a2c48c0bd00965": "cfd0f4278651ae4aaa3477512490936e",
".git/objects/f8/b93620b27f98ae2ff96ec5e6218d904aa581b3": "146aee4ada87de59d75735aceed98520",
".git/objects/ce/bdc60667b60fc3d2fa0e413069e0fb3bd4f2e7": "35ac03200f4c40102fc7c1c06e5147f2",
".git/objects/2c/206cfc19664408675fd65169fbb53bd5086798": "d217f2d427e805d65d3275a19bebcf50",
".git/objects/41/8dbf7970575867b5c949e6a24960b4632b79cf": "889646155be38cbb85426fe21521ee24",
".git/objects/83/63f29f5543bbee76489d8f2b68d41939220dd7": "9fe9a5fa3ec69a267ce4ec7a8efc5662",
".git/objects/83/9d616f22d1ef46232e607d7162d777ea96520f": "6c7af70c3a54d0f5345d9f34b2314d69",
".git/objects/83/2a7b53b7f0d4d28d87bdfc82f21b9c748103c0": "3abc41ba02343195f7e558354ee3c0b6",
".git/objects/48/5026b8f5c9fdb877033a9c1840105051b76623": "f6ac4c3261b4b257ef988e6131b1b9da",
".git/objects/24/453ed0905c48398b61028dfba6e5edaaec1af7": "ddf78dc84359d6d8304d9556c6e72334",
".git/objects/4f/fbe6ec4693664cb4ff395edf3d949bd4607391": "2beb9ca6c799e0ff64e0ad79f9e55e69",
".git/objects/4f/f7144383adbee696b21ad009be3f3939e13ab6": "89cb442d24f721edd098676ce0e74ad0",
".git/objects/12/fb56a85f72858742b74cf05df12fe4414e147e": "786924bb4c1de8d83cd259f271c0569b",
".git/objects/71/dad63bbd3ce02e2b2c074ed39dbcf543eec425": "b12d9f4d0711081c6c3fee23ff5e25a4",
".git/objects/82/755d465354334a03768bf9809a6c3c302836cf": "8ee5ae2bba7f09acd2159a7a2e8182b1",
".git/objects/40/af1824d4743fb0c3747170c58fb447f541037d": "bdbaba98169f3842e3fcfa80f195ca4f",
".git/objects/40/74c9f615f8efd8e5cd18d3136dd44f65ee64f6": "e346867fc20df4f1da6104200c6ad231",
".git/objects/2e/4fcc87335943455e10309101d5ef4a3883aeac": "d0431e23e37dbe7eac09afcfb069f73b",
".git/objects/2e/67fdced232bc18ca789a1fb63525ba348d3a97": "6d2d7c845ed3ca69996e94d6bd177196",
".git/objects/2b/600f30f3ccc961e9eadb7bf344227f323b53dc": "b66ec3c9c3f5bdd9eb7925707ca0da5c",
".git/objects/47/28dff1722bc9a294ef76f4fab4f329ebb34853": "34714f6fd9b06d0f0b177e62c543f7af",
".git/objects/7a/6c1911dddaea52e2dbffc15e45e428ec9a9915": "f1dee6885dc6f71f357a8e825bda0286",
".git/objects/14/23709a27f2a3d1564b2debaeee547d7307376c": "9793a6373885b60de6111c3b8b3edfac",
".git/objects/22/5744bd6947df637fa2f5dbcc5e7c0dea0a6aa1": "9a92957b4a8b60d7f510b1a0baaae628",
".git/objects/25/f8797ef6db5cb73cd6fa8c2a818c7c6000710d": "eb6be27602ad760d5f86e322e7322e97",
".git/HEAD": "5ab7a4355e4c959b0c5c008f202f51ec",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "70b092bc063574d43e3b762fecc01bbe",
".git/logs/refs/heads/gh-pages": "70b092bc063574d43e3b762fecc01bbe",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-commit.sample": "305eadbbcd6f6d2567e033ad12aabbc4",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/refs/heads/gh-pages": "2ded0c1b5149a1754dd30d9ace10c449",
".git/index": "3b4557be3cb5363bb722cecb4666e37a",
".git/COMMIT_EDITMSG": "45c9eb7fa6e6a781268f8a3b8d62d8b9",
"assets/AssetManifest.json": "c6766acd0aa0d0c84c49deba178dab1f",
"assets/NOTICES": "15cb64949f0946e9ae89ecae3c00e203",
"assets/FontManifest.json": "890e9d8f567d5323f8cf7f083a361e3d",
"assets/AssetManifest.bin.json": "e95cfdc60f701bba9a25e8b75b6f5972",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "3954d4001773d81e3a625978d14721b8",
"assets/packages/flutter_3d_controller/assets/model_viewer.min.js": "11f3833db561a92ac9100cd43d28899b",
"assets/packages/flutter_3d_controller/assets/model_viewer_template.html": "d370dc1bc2b1dd29090c1946dbef646a",
"assets/packages/flutter_inappwebview_web/assets/web/web_support.js": "509ae636cfdd93e49b5a6eaf0f06d79f",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css": "5a8d0222407e388155d7d1395a75d5b9",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html": "16911fcc170c8af1c5457940bd0bf055",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "8c81cdcdc35e95d40d6dfe5af6d09f3f",
"assets/fonts/MaterialIcons-Regular.otf": "f44406be5d032ed54ee47f9db4431b5c",
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
"assets/assets/sky5.webp": "b924cd1437ba1ff94c5abe323a4f3ac1",
"assets/assets/3d/README.md": "99b9c9468d4332a4a1fb534177922126",
"assets/assets/fam.png": "db5038fd1ba909efa71cbe6f17f4d84f",
"assets/assets/loginimage.png": "38dcba98d268c95de410fbde72812679",
"assets/assets/header-bg.webp": "03560c8308f78ddc4dc789b8095d47fa",
"assets/assets/sky4.webp": "6135645bf62ca552886e425a3595bb54",
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
"assets/assets/images/family/pat.png": "569e8c87c18259d3328a61c1b16f5028",
"assets/assets/images/family/mintra.png": "27b23e3b01ee1006cebf28a18053ce67",
"assets/assets/images/family/jaidee.png": "5fde542ea9fa4401544b77f92658b873",
"assets/assets/images/family/my_qr.png": "8e2a1c5b7262cd4f36fb3cbcd721fe33",
"assets/assets/images/family/bangkok_map.png": "5cf849f2320c0c9a9bb3123b91d04f19",
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
"assets/assets/Aerobic2.png": "168656cc81eb79ad844011a46ede1003",
"assets/assets/sky2.webp": "e82d5fa08745a0e55c892919d5b8068b",
"assets/assets/bgsky.png": "24be88e66668879b530a4c0fa1844e38",
"assets/assets/apple.png": "095d8a25bfea5781d05d433d7bc654df",
"assets/assets/sky1.webp": "0e1a382b434ace523d701825958a38f4",
"assets/assets/startaerobic.png": "99429980df8a5899fc0e646b568a2800",
"assets/assets/doctormuscott.png": "6824d82449b9cf4afbef0cc4766076b9",
"assets/assets/header-bg.png": "fa3c5904d832856f641fe00d3c97e865",
"assets/assets/vital.png": "3b1f04d02d98397bb87904596793eccc",
"assets/assets/Pill.png": "6c121ad80abe64de3f757436923cabf7",
"assets/assets/med.png": "b521ede9e64b4eb2b93f6dfff656e859",
"assets/assets/rest.png": "4b4690faa62492d9f9ea235f9fc16e6c",
"assets/assets/volunteer%25203d.png": "783197ba0eef7499a0c504cd68a35885",
"assets/assets/line.png": "b0886ec862a127f5238212c4c1eea61a",
"assets/assets/fonts/GoogleSans-Italic-Variable.ttf": "8db7113e37a6cb5ab1d6ca620dd7081d",
"assets/assets/fonts/GoogleSans-Variable.ttf": "c98a147e31d33b276dbfced370e1348d",
"assets/assets/google.png": "506695b89543550eda834cdbaf31ff3b",
"assets/assets/facebook.png": "672af191f3360f368fae2e4749e61544",
"assets/assets/healthid.png": "4f69f084ec03e7e6693c7e85ceee4584",
"assets/assets/kcal.png": "e457f39734ee586e1e52d1f998b844c5",
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
