import "dart:math";

// This returns a hard-coded list of top 20 representatives on https://mynano.ninja/
const List<String> representatives = [
  'nano_1fnx59bqpx11s1yn7i5hba3ot5no4ypy971zbkp5wtium3yyafpwhhwkq8fc',
  'nano_1i9ugg14c5sph67z4st9xk8xatz59xntofqpbagaihctg6ngog1f45mwoa54',
  'nano_3rpixaxmgdws7nk7sx6owp8d8becj9ei5nef6qiwokgycsy9ufytjwgj6eg9',
  'nano_3uaydiszyup5zwdt93dahp7mri1cwa5ncg9t4657yyn3o4i1pe8sfjbimbas',
  'nano_1f56swb9qtpy3yoxiscq9799nerek153w43yjc9atoaeg3e91cc9zfr89ehj',
  'nano_33ad5app7jeo6jfe9ure6zsj8yg7knt6c1zrr5yg79ktfzk5ouhmpn6p5d7p',
  'nano_396sch48s3jmzq1bk31pxxpz64rn7joj38emj4ueypkb9p9mzrym34obze6c',
  'nano_3caprkc56ebsaakn4j4n7g9p8h358mycfjcyzkrfw1nai6prbyk8ihc5yjjk',
  'nano_1just1zdsnke856mu5pmed1qdkzk6adh3d13iiqr3so66sr8pbcnh15bdjda',
  'nano_3chartsi6ja8ay1qq9xg3xegqnbg1qx76nouw6jedyb8wx3r4wu94rxap7hg',
  'nano_3hjo1cehsxrssawmpew98u4ug8bxy4ppht5ch647zpuscdgedfy1xh4yga7z',
  'nano_3moomoo77b45d1jug8szecomeqnmwgjbue1xaxz95s5338jsp77eho166jd1',
  'nano_1center16ci77qw5w69ww8sy4i4bfmgfhr81ydzpurm91cauj11jn6y3uc5y',
  'nano_3u7d5iohy14swyhxhgfm9iq4xa9yibhcgnyj697uwhicp14dhx4woik5e9ek',
  'nano_3om9m65hb6c3xaqkhqpok48wq4dgxidnxt8fihknbsb8pf997iu6dx6x6mfu',
  'nano_3akecx3appfbtf6xrzb3qu9c1himzze46uajft1k5x3gkr9iu3mw95noss6i',
  'nano_1asau6gr8ft5ykynpkauctrq1w37sdasdymuigtxotim6kxoa3rgn3dpenis',
  'nano_3afmp9hx6pp6fdcjq96f9qnoeh1kiqpqyzp7c18byaipf48t3cpzmfnhc1b7',
  'nano_3tsokfobsdsma1k7r76gijt6qfxra5pbq6r83rg34qgwwst8u43mszstk531',
  'nano_1eeiwmnsq6fdhy1m35og1dzt7kdnci8wny3kn771638dfrrgg49so7k1mg7i',
];

getRandomRepresentative() {
  final random = new Random();
  final rep = representatives[random.nextInt(representatives.length)];
  return rep;
}
