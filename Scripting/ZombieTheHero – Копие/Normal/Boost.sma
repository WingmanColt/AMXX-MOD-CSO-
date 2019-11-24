#include <amxmodx> 

new const Zemlje[][] =
{
"Serbia", "Croatia", "Bosnia and Herzegovina",
"Macedonia", "Montenegro", "Norway", "Bugaria", "Chez Republic",
"Finland", "Romania", "Kosovo (Pokrajina - Kosovo is Serbia!)", 
"Albania", "Austria", "Germany",
"Switzerland", "Poland", "Slovenia",
"Sweden", "Italy", "Argentina",
"Brasil", "Peru", "Greece", "India"
}

new const Brojevi[][] =
{
"1310", "866866", "091810700", "141551",
"14741", "2201", "1916", "90703", "17163",
"1261", "55050", "54345", "0900506506",
"89000", "565", "7668", "3838", "72401",
"4885886", "2253", "49602", "35100",
"54344", "8111811140"
}

new const SadrzajSmsa[][] =
{
"100", "TXT6", "TXT",
"TAP", "FOR", "TXT",
"TXT", "TXT3", "TXT",
"TXT", "TXT", "TXT",
"TXT", "TXT", "FOR",
"TAP", "TXT", "TXT",
"TXT", "TXT1", "FOR",
"FOR", "TXT", "TXT",
"GMT"
}

new const CeneSmsova[][] =
{
"120,00 RSD + Price ordinary SMS-a",
"6,20 KN", "2,00 BAM + PDV",
"59.00 MKD", "1.00 Euro", "10,00 NOK", "2,40 BGN", "30.00", "1,00 Euro",
"1.00 Euro + TVA", "1.00 Euro", "120.00 ALL", "1.10 Euro", "1.0 Euro",
"2.00 CHF", "7.38 PLN", "1.0 Euro",
"15,00 SEK", "1.50 Euro", "12 ARS",
"R$ 4,00 + tributos", "7.00 PEN",
"1.23 Euro", "99.00 INR"
}

new const ImenaKomandi[][]=
{
"say /boost",
"say_team /boost"
}

new const SadrzajLangDatoteke[][] = 
{
"[en]",
"ML_REKLAMA = To learn how to boost",
"ML_DA_BOOSTUJES_IZ = To boost from",
"ML_POSALJI_SMS = Send SMS to",
"ML_SMS_FORMAT = SMS Format (Content of Message - Message Body)",
"ML_TEKST_ZA_SLANJE = %s GTRS 95.158.148.253:27019",
"ML_CENA_SMSA = SMS Price",
"ML_VISE_INFO = For more info visit GameTracker.rs",
"ML_NASLOV_ZEMLJE_MENIJA = Select a Country:",
" "

}

new Nick[32], NaslovMenija[32];

public plugin_init()
{
for(new i=0;i< sizeof ImenaKomandi;i++)
register_clcmd(ImenaKomandi[i], "IzaberiDrzavu");

register_dictionary("htbs_bym.txt")
}

public plugin_precache()
{	
if(!file_exists("addons/amxmodx/data/lang/htbs_bym.txt"))
{
for(new i=0;i< sizeof SadrzajLangDatoteke;i++)
{
write_file("addons/amxmodx/data/lang/htbs_bym.txt", SadrzajLangDatoteke[i]);
}
}

}

public IzaberiDrzavu(id)
{
formatex(NaslovMenija, charsmax(NaslovMenija), "%L", id, "ML_NASLOV_ZEMLJE_MENIJA")
new meni = menu_create(NaslovMenija, "IzaberiDrzavuFunkcija");
for(new i=0;i<sizeof Zemlje;i++)
menu_additem(meni, Zemlje[i]);
menu_display(id, meni);
}

public IzaberiDrzavuFunkcija(id, meni, stavka)
{
if(stavka == MENU_EXIT)
{
menu_destroy(meni);
return PLUGIN_CONTINUE;
}

PrikaziKakoBoostovati(id, stavka);
return PLUGIN_CONTINUE 
}

public PrikaziKakoBoostovati(id, Stavka)
{
static motd[2001], Linija, IpServera[32];
get_user_name(id, Nick, 31);
Linija = format(motd, 2000,"<!DOCTYPE html><html><head><title>HTBS BYM</title></head><body bgcolor='#FFFFFF'>")
Linija += format(motd[Linija], 2000-Linija,"<font style='font-family:Arial, Helwetica, Sans-Serif;font-weight:Bold;font-size:15px;'>");
Linija += format(motd[Linija], 2000-Linija,"<span style='color:black'>%L:</span><span style='color:#3399ff'> %s</span><br />", id, "ML_DA_BOOSTUJES_IZ", Zemlje[Stavka]);
Linija += format(motd[Linija], 2000-Linija,"<span style='color:black'>%L:</span><span style='color:#3399ff'> %s</span><br />", id, "ML_POSALJI_SMS", Brojevi[Stavka]);
Linija += format(motd[Linija], 2000-Linija,"<span style='color:black'>%L:</span><br />", id, "ML_SMS_FORMAT");
Linija += format(motd[Linija], 2000-Linija,"<span style='color:red'>%L</span><br />", id, "ML_TEKST_ZA_SLANJE", SadrzajSmsa[Stavka], IpServera, Nick);
Linija += format(motd[Linija], 2000-Linija,"<span style='color:black'>%L:</span><br /><span style='color:#3399ff'> %s</span><br />", id, "ML_CENA_SMSA", CeneSmsova[Stavka]);
Linija += format(motd[Linija], 2000-Linija,"<span style='color:green'>%L</span><br />", id, "ML_VISE_INFO");
Linija += format(motd[Linija], 2000-Linija,"</font></body></html>")
show_motd(id, motd, "How to boost")
return 0
}


