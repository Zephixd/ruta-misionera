import '../models/sitio.dart';

/// Datos iniciales (Seed) de los sitios turísticos e históricos de Misiones, Paraguay.
///
/// **Nota para el estudiante:**
/// Las coordenadas geográficas son aproximadas y deben verificarse con GPS o Google Maps
/// antes de la demostración final en clase. Cada una está marcada con `// TODO: verificar coordenadas`.
class SeedSitios {
  static const List<Sitio> sitiosIniciales = [
    // 1. Iglesia de San Ignacio
    Sitio(
      id: 'san_ignacio_guazu',
      nombre: 'Iglesia de San Ignacio',
      nombreGuarani: 'Tupao San Ignacio',
      descripcion: 'Templo histórico erigido sobre el predio de la primera reducción jesuítica de 1609.',
      historia: 'Ubicada en el corazón de San Ignacio Guazú, frente a la plaza central. Erigida sobre el solar histórico de la reducción fundada en 1609 por los padres jesuitas Marcial de Lorenzana y Francisco de San Martín.',
      categoria: 'mision_jesuitica',
      lat: -26.888963631870944,
      lng: -57.02394436071927,
      imagenAsset: 'assets/images/san_ignacio.png',
      radioCheckInMetros: 150.0,
      comentariosCount: 5,
      esUnesco: false,
    ),

    // 2. Museo de Arte Jesuítico Guaraní Santa María de Fe
    Sitio(
      id: 'santa_maria_de_fe',
      nombre: 'Museo de Arte Jesuítico de Santa María',
      nombreGuarani: 'Taruma',
      descripcion: 'Ubicado en la antigua «Casa de los Indios» de 1672, alberga una invaluable colección de más de 50 tallas barroco-guaraníes.',
      historia: 'El Museo Diocesano de Arte Jesuítico de Santa María de Fe se encuentra ubicado en el casco urbano de Santa María de Fe, departamento de Misiones, justo al lado del templo parroquial.\n\nFunciona en la antigua «Casa de los Indios» de la misión (edificación histórica de 1672 que aún conserva paredes de tapia gruesa, techo de tacuará con grandes tejas y los aros de hierro originales donde colgaban las hamacas). Alberga alrededor de 56 tallas de madera policromadas de estilo barroco hispano-guaraní de los siglos XVII y XVIII distribuidas en seis salas temáticas, entre ellas escenas del nacimiento de Jesús con animales autóctonos y un cielo raso estrellado colonial.\n\nCosto de entrada: Gs. 20.000 por persona. Atiende de lunes a domingos (consultas y reservas: +595 975 618461 / +595 971 677551).',
      categoria: 'museo',
      lat: -26.782316810228558,
      lng: -56.943702377364296,
      imagenAsset: 'assets/images/santa_maria.png',
      radioCheckInMetros: 150.0,
      comentariosCount: 3,
      esUnesco: false,
    ),

    // 3. Torreón Jesuítico de Santa Rosa de Lima
    Sitio(
      id: 'santa_rosa_de_lima',
      nombre: 'Torreón Jesuítico de Santa Rosa',
      nombreGuarani: 'Santa Rosa Misiones',
      descripcion: 'Histórica torre de piedra roja al costado de la Plaza Mariscal Estigarribia, único sobreviviente del incendio de 1883.',
      historia: 'El Torreón Jesuítico de Santa Rosa de Lima es una histórica torre de piedra roja de la reducción fundada en 1698, ubicada al costado de la Plaza Mariscal Estigarribia en Santa Rosa, Misiones, Paraguay.\n\nEs el único sobreviviente del incendio de 1883 que destruyó la iglesia original de la reducción. Funciona como campanario y símbolo insigne de la herencia jesuítica en la región, restaurado y puesto en valor patrimonial.',
      categoria: 'mision_jesuitica',
      lat: -26.887091339542767,
      lng: -56.84926853717518,
      imagenAsset: 'assets/images/santa_rosa.png',
      radioCheckInMetros: 150.0,
      comentariosCount: 4,
      esUnesco: false,
    ),

    // 4. Santiago - Tesoros Jesuíticos
    Sitio(
      id: 'santiago_apostol',
      nombre: 'Tesoros Jesuíticos Santiago',
      nombreGuarani: 'Santiago Misiones',
      descripcion: 'Posee el mejor centro histórico urbano-jesuítico y el Museo Tesoros Jesuíticos con tallas de madera únicas y retablo barroco.',
      historia: 'Ubicada a 275 Km de Asunción (desvío en el Km 257 de la Ruta PY01, luego a 18 Km por supercarretera a Ayolas), en el departamento de Misiones, posee el mejor centro histórico urbano-jesuítico, con las casas de indígenas bordeando la plaza. Cuenta con un museo de gran valor arqueológico y de un estilo particular debido a su posible influencia flamenca. La iglesia actual posee un retablo de altar barroco, quizás único entre los restos de las Misiones, e imágenes de Santiago Apóstol y San Isidro, entre otras.\n\nFue una de las misiones más pequeñas pero la que mejor conserva las tallas de madera, guardadas en el Museo Tesoros Jesuíticos. Destacan las imágenes de la Virgen de la Cabeza, de la Piedad y la de Jesús Resucitado, así como las estatuas de San Luis Gonzaga y de San Ignacio. A ellas se suman las pinturas realizadas en las misiones y las construcciones en adobe que fueron las casas de los indígenas y que en la actualidad pueden apreciarse en la plaza.',
      categoria: 'mision_jesuitica',
      lat: -27.141103570171868,
      lng: -56.763653802812335,
      imagenAsset: 'assets/images/santiago.jpg',
      radioCheckInMetros: 150.0,
      comentariosCount: 2,
      esUnesco: false,
    ),

    // 5. Ruinas de la Misión Jesuítica Guaraní de la Santísima Trinidad del Paraná (UNESCO)
    Sitio(
      id: 'trinidad_del_parana',
      nombre: 'Ruinas de la Santísima Trinidad del Paraná',
      nombreGuarani: 'Trinidad Itapúa',
      descripcion: 'Patrimonio de la Humanidad UNESCO. La reducción jesuítica más extensa y mejor conservada del Paraguay.',
      historia: 'Las Ruinas de la Misión Jesuítica Guaraní de la Santísima Trinidad del Paraná son la reducción jesuítica más extensa y mejor conservada de Paraguay. Fundada originalmente en 1706, representa el máximo esplendor del urbanismo jesuítico y la fusión cultural del barroco guaraní. Declarada Patrimonio de la Humanidad por la UNESCO en 1993.\n\nDiseñada por el arquitecto Juan Bautista Prímoli, destaca por la Iglesia Mayor en piedra arenisca (itaky) con el célebre friso de los ángeles músicos, su imponente Plaza Mayor de 150x130 metros y el Museo Jesuítico con esculturas coloniales.\n\nUbicación: Distrito de Trinidad, Itapúa (Ruta PY06, a 28 km de Encarnación). Cuenta con boleto unificado para Trinidad, Jesús y San Cosme (Gs. 25.000 nacionales, Gs. 40.000 extranjeros) y espectáculo nocturno de luces y sonidos de miércoles a domingos.',
      categoria: 'mision_jesuitica',
      lat: -27.131877356766353,
      lng: -55.70191304515738,
      imagenAsset: 'assets/images/trinidad.png',
      radioCheckInMetros: 150.0,
      comentariosCount: 8,
      esUnesco: true,
    ),

    // 6. Reducciones de la Misión Jesuítica Guaraní de Jesús de Tavarangüé (UNESCO)
    Sitio(
      id: 'jesus_de_tavarangue',
      nombre: 'Misión Jesuítica de Jesús de Tavarangüé',
      nombreGuarani: 'Tavarangue',
      descripcion: 'Patrimonio de la Humanidad UNESCO. Monumental iglesia inconclusa con arcos trilobulados de estilo mudéjar únicos en la región.',
      historia: 'Las Reducciones de la Misión Jesuítica Guaraní de Jesús de Tavarangüé son uno de los tesoros arqueológicos más importantes de Paraguay, declaradas Patrimonio de la Humanidad por la UNESCO en 1993.\n\nFundada en 1685 y trasladada a su sitio actual en 1706, su monumental iglesia quedó congelada en el tiempo por la expulsión de los jesuitas en 1767, mostrando cómo era un sitio de construcción colonial en el siglo XVIII. Destacan sus tres portales con arcos trilobulados de estilo mudéjar (cristiano-árabe), únicos en las misiones jesuíticas.\n\nCuenta con espectáculo nocturno de videomapping 3D y museo de sitio. El boleto unificado (Gs. 25.000 nacionales, Gs. 40.000 extranjeros) es válido por 72 horas para Jesús de Tavarangüé, Santísima Trinidad y San Cosme y Damián.',
      categoria: 'mision_jesuitica',
      lat: -27.05494879119155,
      lng: -55.752561925722375,
      imagenAsset: 'assets/images/tavarangue.png',
      radioCheckInMetros: 150.0,
      comentariosCount: 6,
      esUnesco: true,
    ),

    // 7. Museo Diocesano de San Ignacio Guazú
    Sitio(
      id: 'museo_diocesano_san_ignacio',
      nombre: 'Museo Diocesano de San Ignacio Guazú',
      nombreGuarani: 'Tembikuaaty San Ignacio',
      descripcion: 'Primer museo jesuítico-guaraní del país, ubicado en el antiguo colegio colonial de adobe con más de 30 esculturas sacras.',
      historia: 'El Museo Diocesano de San Ignacio Guazú es el primer museo jesuítico-guaraní de Paraguay y una joya histórica situada en el departamento de Misiones. Se asienta en el antiguo colegio indígena colonial, una de las pocas estructuras de adobe de las reducciones que aún se mantiene en pie y en uso en todo el país.\n\nAlberga unas 30 magníficas esculturas de madera policromada talladas a mano en el siglo XVII, combinando técnicas europeas con la cosmovisión guaraní. Se distribuye en cuatro salas temáticas: La Creación (con San Miguel Arcángel y un gran púlpito), Misterio Pascual (Redención), Historia de Cristo en la Iglesia y La Compañía de Jesús. Además, funciona como museo vivo con talleres de arte tradicional. Entrada: Gs. 20.000, con códigos QR para audioguías en español e inglés.',
      categoria: 'museo',
      lat: -26.890405555337537,
      lng: -57.02378193085008,
      imagenAsset: 'assets/images/museo_jesuitico.png',
      radioCheckInMetros: 150.0,
      comentariosCount: 3,
      esUnesco: false,
    ),

    // 8. La Arcadia Restaurant & Cultura
    Sitio(
      id: 'gastronomia_misiones',
      nombre: 'La Arcadia Restaurant',
      nombreGuarani: 'La Arcadia - Tembi\'u',
      descripcion: 'Emblemático restaurante y espacio cultural en una casona histórica con paredes y techos decorados con arte barroco jesuítico.',
      historia: 'La Arcadia es uno de los restaurantes y puntos culturales más emblemáticos de San Ignacio Guazú, Misiones, ideal para quienes buscan una experiencia que combina gastronomía e historia regional.\n\nFunciona en una antigua casona histórica cuyas paredes y techos están decorados con pinturas que rescatan el estilo barroco de las reducciones jesuíticas. Su propuesta gastronómica fusiona recetas tradicionales paraguayas, platos regionales con marcada influencia misionera y cocina internacional, complementada con cafetería, vinos y noches de música en vivo.\n\nUbicación: Calle Iturbe en el casco histórico de San Ignacio Guazú. Cuenta con estacionamiento propio, mesas al aire libre y accesibilidad.',
      categoria: 'gastronomia',
      lat: -26.888201305348254,
      lng: -57.02308770068655,
      imagenAsset: 'assets/images/gastronomia.png',
      radioCheckInMetros: 150.0,
      comentariosCount: 7,
      esUnesco: false,
    ),
  ];
}
