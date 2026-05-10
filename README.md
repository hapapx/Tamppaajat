# Pika-aloitus
Jos haluat kokeilla peliäni, se löytyy tiedostona polusta **build/Tamppaajat.prg**. Voit ajaa tämän suoraan oman koneesi emulaattorissa tai heittää johonkin online-emulaattoriin (esim. https://c64online.com/c64-online-emulator).

# Infoa

Tässä repossa ovat lähdekoodit ja suoraan emulaattorissa ajettavaksi käännetty tiedosto Commodore 64:n konekielellä toteutetusta koodausprojektistani. Urakan lopputuloksena syntyi Tamppaajat-peli, joka perustuu Kummelin 1990-luvulla tekemään sketsiin (ks. https://yle.fi/a/20-102659). Opettelin C64:n konekieltä sitä mukaa, kun pelin kehitys eteni, eikä lähdekoodeistani kannata ottaa esimerkkiä. 

Suoritin koodauksen Visual Studio Codella ja projektin määrittely on repon tiedostossa src/AssemblerTest.code-workspace. Voi olla, että jotain paikallisia polkuja joudut asettamaan uusiksi, mikäli tuota yrität käyttää. Lähdekoodit ovat tiedostoissa src/*.asm. Visual Studion Codessa käytin VS64-laajennosta koodin kirjoittamiseen ja ACME-assembleria sen kääntämiseen. Tarkempaa kuvausta projektistani löytyy Skrolli-lehden (https://skrolli.fi) numerosta 2025/4.

Suurin motivaationi pelin edistämiseen hiipui, kun olin saanut sen nykyiseen toimivaan tilaan, jossa kentissä on aikaraja ja lumen määrä lisääntyy kentästä toiseen. Joitain pieniä varmasti vielä esiintyy, mutta isompien tekemättömien asioiden listalla ovat mm.

- Äänitehosteet. Jonkinlaiset hahmon liikkumisen mukaan tulevat suhahdukset olisivat paikallaan.
- Alkuruutu
- Pisteiden lasku. Sen sijaan, että pelissä tulisi vain selvitä kentästä toiseen, olisi kiva saada mukaan pisteytys. Tästä seuravana askeleena myös parhaiden tulosten tallennus.
- Tarkempi lumialueiden tamppaus ilman, että tulee harmaita neliöitä
- Pelaajan hidastuminen lumialueen ulkopuolella
