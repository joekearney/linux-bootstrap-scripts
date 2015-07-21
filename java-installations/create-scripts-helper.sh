#!/bin/bash
shopt -s expand_aliases
alias echo='echo -e'
declare -i dupecheck=0
creatediryn=""
inun=""
once="0"
basejdir="/opt/java/current-java"
######
# funcs
######
usage() {
        echo "#### this tool supplies the appropriate update-alternatives commands, it does NOT execute the commands for you"
        echo "#### usage: $0 -i|-r [-heb]"
        echo "#### \t -h|--help\t\t show this"
        echo "#### \t -e|--examples\t\t show some examples"
        echo "#### \t -i|--install\t\t provide the installation commands"
        echo "#### \t -r|--remove\t\t provide the removal commands"
        echo "#### \t -b|--basedir /example/java/directory\t specify the base java directory (default: $basejdir)"
 
if [ "$#" -gt 0 ]; then
        echo "####################"
        echo "## helper.tool -i"
        echo " Display java installation commands in terminal"
        echo " This assumes that $basejdir is a symlink pointing to the jdk folder (for example /opt/java/jdk1.7.0_67)"
 
        echo "\n### helper.tool -i -b /opt/java/64/current-java"
        echo " Display installation commands which use /opt/java/64/current-java as the base directory"
        echo " ie: /opt/java/64/current-java could be a symlink which points to /opt/java/jdk1.7.0_67-amd64"
 
        echo "\n### helper.tool -i -b /home/`whoami`/java-installation"
        echo " Display installation commands which use /home/`whoami`/java-installation as the base directory"
        echo " ie: you have installed java into /home/`whoami`/java-installation"
 
        echo "\n## helper.tool -r"
        echo " Display java removal commands in terminal"
        echo " This assumes that $basejdir is a symlink pointing to a jdk folder such as /opt/java/jdk1.8"
fi
 
        quit 0
}
quit() {
        unalias echo
        shopt -u expand_aliases
        unset inun once basejdir creatediryn binlist jrebinlist i k dupecheck
        exit $1
}
 
# https://gist.github.com/cosimo/3760587
OPTS=`getopt -o hirb:e --long help,install,remove,basedir,examples -n 'parse-options' -- "$@"`
if [ $? != 0 ]; then echo "Failed parsing options..."; quit 1; fi
eval set -- "$OPTS"
 
# parse options
while true; do
        case "$1" in
                ( -h | --help )
                        usage
                        ;;
                ( -i | --install )
                        ((dupecheck++))
                        inun="in"
                        ;;
                ( -r | --remove )
                        ((dupecheck++))
                        inun="un"
                        ;;
                ( -b | --basedir )
                        shift
                        basejdir="$1"
                        ;;
                ( -e | --examples )
                        usage "e"
                        ;;
                ( -- ) shift; break ;;
                ( -* ) echo "$0 - unrecognized option: $1"; usage;;
                ( * ) break ;;
        esac
        shift
done
 
# did they choose a mode?
#if [ -z "$inun" ]; then echo "please select either -i or -r\n"; usage; fi
# the line above this effectively does the same thing but i feel like an integer comparison would be more efficient ... idk
if [ $dupecheck -gt 1 ]; then echo "please select either -i or -r\n"; usage; fi
 
# check that the java base directory exists
if [ ! -d "$basejdir" ]; then
        echo -n "the java base directory $basejdir doesn't exist. create it? "
        while true; do
            read -p "[Y/n] " -e creatediryn
            case $creatediryn in
                [Yy]* )
                        echo -n "sudo mkdir -p $basejdir: "
                        sudo mkdir -p $basejdir
                        if [ ! -d $basejdir ]; then echo "i couldn't create $basejdir!"; quit 1; fi
                        break;;
                [Nn]* ) exit;;
                * ) ;;
            esac
        done
 
        #echo "you need to create the current-java symlink which points to the most recent jdk folder"
        #echo "for example: sudo ln -s /opt/java/jdk1.7.0_67 /opt/java/current-java"
fi
 
# does the jdk/jre directory structure exist?
if [[ ! -d "$basejdir/bin" || ! -d "$basejdir/jre/bin" ]]; then echo "please extract the jdk/jre files into $basejdir"; quit 0; fi
 
# files in /opt/java/current-java/bin take precedence over those in jre/bin i think
cd $basejdir/bin
binlist="`/bin/ls -1 *`"
 
echo "######## system config for $basejdir/bin/"
echo "###########################################"
for i in $binlist; do
        # im not sure about this one ... seems like it could be ambiguous
        if [ "$i" == "ControlPanel" ]; then
                echo "# the file $basejdir/bin/ControlPanel was ignored"
                continue
        fi
 
        # display the appropriate command (using either --install&--set or --remove)
        if [ "$inun" == "in" ]; then
                # handle .../lib/jexec manually
                if [ "$once" == "0" ]; then
                        echo "update-alternatives --install /usr/bin/jexec jexec $basejdir/lib/jexec 1065 && sleep 1s"
                        echo "update-alternatives --set jexec $basejdir/lib/jexec && sleep 1s"
                        once="1"
                fi
 
                # display upd-alt command
                echo "update-alternatives --install /usr/bin/$i $i $basejdir/bin/$i 1065 && sleep 1s"
                echo "update-alternatives --set $i $basejdir/bin/$i && sleep 1s"
        elif [ "$inun" == "un" ]; then
                # handle .../lib/jexec manually
                if [ "$once" == "0" ]; then
                        echo "update-alternatives --remove jexec $basejdir/lib/jexec && sleep 1s"
                        once="1"
                fi
 
                # display upd-alt command
                echo "update-alternatives --remove $i $basejdir/bin/$i && sleep 1s"
        fi
done
 
 
 
echo "######## system config for $basejdir/jre/bin/"
echo "###########################################"
cd $basejdir/jre/bin
jrebinlist="`/bin/ls -1 *`"
 
for i in $jrebinlist; do
        # im not sure about this one ... seems like it could be ambiguous
        if [ "$i" == "ControlPanel" ]; then
                echo "# the file $basejdir/bin/ControlPanel was ignored"
                continue
        fi
 
        # jexec has already been added/removed
        if [ "$i" == "jexec" ]; then continue; fi
 
        #dont show commands for files that have already been printed
        # (the files in .../bin/ and .../jre/bin are duplicate. you can confirm this by md5sum'ing them and comparing the result)
        for k in $binlist; do
                if [ "$i" == "$k" ]; then
                        #echo "# skipping duplicate file: $i / $k"
                        skip="y"
                        break
                fi
                skip="n"
        done
 
        # non-duplicate file ... print command
        if [ "$skip" == "n" ]; then
                if [ "$inun" == "in" ]; then
                        echo "update-alternatives --install /usr/bin/$i $i $basejdir/jre/bin/$i 1065 && sleep 1s"
                        echo "update-alternatives --set $i $basejdir/jre/bin/$i && sleep 1s"
                        skip="n"
                elif [ "$inun" == "un" ]; then
                        echo "update-alternatives --remove $i $basejdir/jre/bin/$i && sleep 1s"
                fi
        fi
done
 
echo "\n# finished! here's how you can use them:"
echo "#\t1. copy the commands into a textfile called updatesystem.txt \n"
echo "#\t2. save the textfile into your home folder like this: /home/`whoami`/updatesystem.txt"
echo "#\t3. open a terminal and execute this command:"
echo "#\t       chmod +x /home/`whoami`/updatesystem.txt"
echo "#\t4. execute this command:"
echo "#\t       /bin/bash /home/`whoami`/updatesystem.txt"
echo "#\t\t Java is now installed!"
