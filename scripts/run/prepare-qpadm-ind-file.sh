###############################################
# bash script for preparing copy of ind file
# used in qpAdm analysis.
#############################


###############################################
# %_DATADIR% in two paths below should be set
# to path of directory cotnaining ind file.
# Modified ind file is generated in the same dir.
# the %_DATADIR% tag is replaced by configureScripts.sh
#################################################
sourceIndFile=%DATADIR%/ancient_genomes.v54.ind
file=%DATADIR%/ancient_genomes.v54.qpadm.ind
sampleFile=`dirname $0`/../sample-info.tsv

cp $sourceIndFile $file

#################################################
# Define individual pop labels for all individuals
# listed in the sample file and analyzed by qpAdm
#################################################
inds=`tail -n+2 $sampleFile | cut -f1`
for ind in $inds; do sed -r -i 's/^('$ind'[[:space:]]+[MF]).*/\1 '$ind'/' $file ; done


#################################################
#  Define 14 pop labels for 23 anient individuals
#  used for defining background ancestry (
#  right pops)  
#################################################
pop="ElMiron_back"                ; inds="ElMiron_d"
for ind in $inds; do sed -r -i 's/^('$ind'[[:space:]]+[MF]).*/\1 '$pop'/' $file ; done

pop="Ust_Ishim_back"              ; inds="Ust_Ishim.DG"
for ind in $inds; do sed -r -i 's/^('$ind'[[:space:]]+[MF]).*/\1 '$pop'/' $file ; done

pop="Kostenki14_back"             ; inds="Kostenki14"
for ind in $inds; do sed -r -i 's/^('$ind'[[:space:]]+[MF]).*/\1 '$pop'/' $file ; done

pop="GoyetQ116_back"              ; inds="GoyetQ116-1_noUDG"
for ind in $inds; do sed -r -i 's/^('$ind'[[:space:]]+[MF]).*/\1 '$pop'/' $file ; done

pop="Vestonice16_back"            ; inds="Vestonice16"
for ind in $inds; do sed -r -i 's/^('$ind'[[:space:]]+[MF]).*/\1 '$pop'/' $file ; done

pop="MA1_back"                    ; inds="MA1_noUDG.SG"
for ind in $inds; do sed -r -i 's/^('$ind'[[:space:]]+[MF]).*/\1 '$pop'/' $file ; done

pop="Villabruna_back"       ; inds="Villabruna_noUDG"
for ind in $inds; do sed -r -i 's/^('$ind'[[:space:]]+[MF]).*/\1 '$pop'/' $file ; done

pop="CHG_back"                    ; inds="KK1_noUDG.SG SATP_noUDG.SG"
for ind in $inds; do sed -r -i 's/^('$ind'[[:space:]]+[MF]).*/\1 '$pop'/' $file ; done

pop="EHG_back"                    ; inds="I0061 I0124 I0211"
for ind in $inds; do sed -r -i 's/^('$ind'[[:space:]]+[MF]).*/\1 '$pop'/' $file ; done

pop="WHG_back"                    ; inds="I0585 I1507"
for ind in $inds; do sed -r -i 's/^('$ind'[[:space:]]+[MF]).*/\1 '$pop'/' $file ; done

pop="Mota_back"                   ; inds="mota_noUDG.SG"
for ind in $inds; do sed -r -i 's/^('$ind'[[:space:]]+[MF]).*/\1 '$pop'/' $file ; done

pop="Natufian_back"               ; inds="I0861"
for ind in $inds; do sed -r -i 's/^('$ind'[[:space:]]+[MF]).*/\1 '$pop'/' $file ; done

pop="Levant_N_back"               ; inds="I1699 I1707 I1710 I0867"
for ind in $inds; do sed -r -i 's/^('$ind'[[:space:]]+[MF]).*/\1 '$pop'/' $file ; done

pop="Tunisia_N_back"              ; inds="I22867 I22862 I22577"
for ind in $inds; do sed -r -i 's/^('$ind'[[:space:]]+[MF]).*/\1 '$pop'/' $file ; done

################################################
# Define ancestry labels for ancient indiviauls
# grouped into eight groups used as proxies
# to ancestry sources in qpAdm
################################################

pop="Greece_BA_Myc_source"        ; inds="I9006 I9010 I9033 I9041 I13514 I13518 I13577 I15571 I15582 I19366"
for ind in $inds; do sed -r -i 's/^('$ind'[[:space:]]+[MF]).*/\1 '$pop'/' $file ; done

pop="Sicily_EMBA_source"           ; inds="I3122 I3123 I3124 I7796 I7807 I11442 I22238 I22241 I22242 I22234"
for ind in $inds; do sed -r -i 's/^('$ind'[[:space:]]+[MF]).*/\1 '$pop'/' $file ; done

pop="Steppe_MLBA_source"          ; inds="I0232 I0234 I0235 I0359 I0361 I0422 I0423 I0424 I0430 I0431"
for ind in $inds; do sed -r -i 's/^('$ind'[[:space:]]+[MF]).*/\1 '$pop'/' $file ; done

pop="Sardinia_LBA_source"         ; inds="I3642 I3741 I10364 I10552 I10553 I10554"
for ind in $inds; do sed -r -i 's/^('$ind'[[:space:]]+[MF]).*/\1 '$pop'/' $file ; done

pop="Iberia_EBA_source"           ; inds="I3997 I4561 I4560 I4562 I3494 I6470 I6470 I1840 I3756 I8136 VAD001"
for ind in $inds; do sed -r -i 's/^('$ind'[[:space:]]+[MF]).*/\1 '$pop'/' $file ; done

pop="Iran_N_source"               ; inds="AH1_noUDG.SG AH2_noUDG.SG AH4_noUDG.SG I1290 I1945 I1949 WC1_noUDG.SG"
for ind in $inds; do sed -r -i 's/^('$ind'[[:space:]]+[MF]).*/\1 '$pop'/' $file ; done

pop="Levant_MLBA_source"          ; inds="I2062 I3965 I3966 I10092 I10093 I10097 I10099 I10268 I10770 I10771 I8187 I10768 I2190 I3832 I2198 I10264 I4518 I2195 I10106 I10266 I4525 I7003 I4519 I10104"
for ind in $inds; do sed -r -i 's/^('$ind'[[:space:]]+[MF]).*/\1 '$pop'/' $file ; done

pop="North_Africa_IA_source"      ; inds="I12433"
for ind in $inds; do sed -r -i 's/^('$ind'[[:space:]]+[MF]).*/\1 '$pop'/' $file ; done
