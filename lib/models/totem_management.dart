/// ------------------ MODELOS ------------------
class ItemPosition {
  final double lat;
  final double lng;
  const ItemPosition({required this.lat, required this.lng});
}

class ItemSources {
  final String glb;
  final String img;
  const ItemSources({required this.glb, required this.img});
}

class ItemAR {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final ItemPosition position;
  final ItemSources sources;
  const ItemAR({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.position,
    required this.sources,
  });
}

/// ------------------ DATA (paths reales) ------------------
final List<ItemAR> itemsSources = [
  ItemAR(
    id: "taita",
    title: "Taita Imbabura – El Abuelo que todo lo ve",
    subtitle: "Ñawi Hatun Yaya",
    description: "Sabio y protector, guardián del viento.",
    position: ItemPosition(lat: 0.20477, lng: -78.20639),
    sources: ItemSources(
      glb:
          "https://meetclic.com/public/simi-rura/muelle-catalina//taita-imbabura-toon-1.glb",
      img:
          "https://meetclic.com/public/simi-rura/muelle-catalina//images/taita-imbabura.png",
    ),
  ),
  ItemAR(
    id: "cerro-cusin",
    title: "Cusin – El guardián del paso fértil",
    subtitle: "Allpa ñampi rikchar",
    description: "Alegre y trabajador, cuida las chacras.",
    position: ItemPosition(lat: 0.20435, lng: -78.20688),
    sources: ItemSources(
      glb: "https://meetclic.com/public/simi-rura/muelle-catalina/cusin.glb",
      img:
          "https://meetclic.com/public/simi-rura/muelle-catalina/images/elcusin.png",
    ),
  ),
  ItemAR(
    id: "mojanda",
    title: "Mojanda – El susurro del páramo",
    subtitle: "Sachayaku mama",
    description: "Entre neblinas y lagunas, hilos de agua fría que renuevan.",
    position: ItemPosition(lat: 0.20401, lng: -78.20723),
    sources: ItemSources(
      glb:
          "https://meetclic.com/public/simi-rura/muelle-catalina/taita-imbabura-otro.glb",
      img:
          "https://meetclic.com/public/simi-rura/muelle-catalina/images/mojanda.png",
    ),
  ),
  ItemAR(
    id: "mama-cotacachi",
    title: "Mama Cotacachi – Madre de la Pachamama",
    subtitle: "Allpa mama- Warmi Rasu",
    description: "Dulce y poderosa, cuida los ciclos de la vida.",
    position: ItemPosition(lat: 0.20369, lng: -78.20759),
    sources: ItemSources(
      glb:
          "https://meetclic.com/public/simi-rura/muelle-catalina/mama-cotacachi.glb",
      img:
          "https://meetclic.com/public/simi-rura/muelle-catalina/images/warmi-razu.png",
    ),
  ),
  ItemAR(
    id: "coraza",
    title: "El Coraza – Espíritu de la celebración",
    subtitle: "Kawsay Taki",
    description: "Orgullo y dignidad; su danza es memoria viva de lucha.",
    position: ItemPosition(lat: 0.20349, lng: -78.20779),
    sources: ItemSources(
      glb:
          "https://meetclic.com/public/simi-rura/muelle-catalina/coraza-one.glb",
      img:
          "https://meetclic.com/public/simi-rura/muelle-catalina/images/elcoraza.png",
    ),
  ),
  ItemAR(
    id: "lechero",
    title: "El Lechero – Árbol del Encuentro y los Deseos",
    subtitle: "Kawsay ranti",
    description: "Testigo de promesas, desde sus ramas el mundo sueña.",
    position: ItemPosition(lat: 0.20316, lng: -78.20790),
    sources: ItemSources(
      glb: "https://meetclic.com/public/simi-rura/muelle-catalina/other.glb",
      img:
          "https://meetclic.com/public/simi-rura/muelle-catalina/images/lechero.png",
    ),
  ),
  ItemAR(
    id: "lago-san-pablo",
    title: "Yaku Mama – La Laguna Viva",
    subtitle: "Yaku Mama – Kawsaycocha",
    description: "Aquí termina el camino y comienza la conexión profunda.",
    position: ItemPosition(lat: 0.20284, lng: -78.20802),
    sources: ItemSources(
      glb:
          "https://meetclic.com/public/simi-rura/muelle-catalina/lago-san-pablo.glb",
      img:
          "https://meetclic.com/public/simi-rura/muelle-catalina/images/yaku-mama.png",
    ),
  ),
  ItemAR(
    id: "ayahuma-pacha",
    title: "Ayahuma",
    subtitle: "Yaku Mama – Kawsaycocha",
    description: "Aquí termina el camino y comienza la conexión profunda.",
    position: ItemPosition(lat: 0.20284, lng: -78.20802),
    sources: ItemSources(
      glb: "https://meetclic.com/public/simi-rura/pacha/ayahuma.glb",
      img: "https://meetclic.com/public/simi-rura/pacha/images/ayahuma.png",
    ),
  ),
  ItemAR(
    id: "corazon-pacha",
    title: "Corazon Pacha",
    subtitle: "Yaku Mama – Kawsaycocha",
    description: "Aquí termina el camino y comienza la conexión profunda.",
    position: ItemPosition(lat: 0.20284, lng: -78.20802),
    sources: ItemSources(
      glb: "https://meetclic.com/public/simi-rura/pacha/corazon.glb",
      img: "https://meetclic.com/public/simi-rura/pacha/images/corazon.png",
    ),
  ),
];
