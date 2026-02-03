dnf install -y yum-utils
yum-config-manager --enable ol9_addons
dnf install oracle-epel-release-el9.x86_64 -y
dnf update -y
dnf install oracle-database-preinstall-19c.x86_64 man unzip chrony cifs-utils screen tmux strace iotop rlwrap make gcc gcc-c++ perl-TermReadKey.x86_64 -y

dnf install oracle-database-preinstall-23ai.x86_64 man unzip chrony cifs-utils screen tmux strace iotop rlwrap make gcc gcc-c++ perl-TermReadKey.x86_64 -y

dnf install https://public-yum.oracle.com/repo/OracleLinux/OL8/appstream/x86_64/getPackage/compat-libpthread-nonshared-2.28-72.0.1.el8_1.1.x86_64.rpm
dnf install https://public-yum.oracle.com/repo/OracleLinux/OL8/appstream/x86_64/getPackage/compat-libpthread-nonshared-2.28-251.0.2.el8_10.14.x86_64.rpm


echo "Oracle123" | passwd --stdin oracle
echo "oracle ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/oracle
mkdir /fra /install /oracle_backup /oradata1 /h510tmp /u01
systemctl enable --now chronyd
systemctl disable --now firewalld
dnf clean all


# KVM
vgcreate $(hostname -s)_u01 /dev/vdb
vgcreate $(hostname -s)_oradata1 /dev/vdc
yes y | lvcreate -l 100%FREE $(hostname -s)_u01
yes y | lvcreate -l 100%FREE $(hostname -s)_oradata1
mkfs.xfs /dev/mapper/$(hostname -s)_u01-lvol0 -f
mkfs.xfs /dev/mapper/$(hostname -s)_oradata1-lvol0 -f
echo "/dev/mapper/$(hostname -s)_u01-lvol0 /u01 xfs noatime 0 0" >> /etc/fstab
echo "/dev/mapper/$(hostname -s)_oradata1-lvol0 /oradata1 xfs noatime 0 0" >> /etc/fstab

# KVM RAC
vgcreate $(hostname -s)_u01 /dev/vdb
lvcreate -l 100%FREE $(hostname -s)_u01
mkfs.xfs /dev/mapper/$(hostname -s)_u01-lvol0 -f
echo "/dev/mapper/$(hostname -s)_u01-lvol0 /u01 xfs noatime 0 0" >> /etc/fstab


systemctl daemon-reload
mount -a
chown oracle:oinstall /u01 
chown oracle:oinstall /oradata1

echo "//h510.balazs.vm/install       /install       cifs _netdev,uid=oracle,gid=oinstall,guest,ro,x-systemd.after=network-online.target 0 0" >> /etc/fstab
echo "//h510.balazs.vm/fra           /fra           cifs _netdev,uid=oracle,gid=oinstall,guest,x-systemd.after=network-online.target    0 0" >> /etc/fstab
echo "//h510.balazs.vm/tmp           /h510tmp       cifs _netdev,uid=oracle,gid=oinstall,guest,x-systemd.after=network-online.target    0 0" >> /etc/fstab
echo "//h510.balazs.vm/oracle_backup /oracle_backup cifs _netdev,uid=oracle,gid=oinstall,guest,x-systemd.after=network-online.target    0 0" >> /etc/fstab
systemctl daemon-reload
mount -a

sed -i s/\#AddressFamily\ any/AddressFamily\ inet/g /etc/ssh/sshd_config


echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "" >> /etc/sysctl.conf

# 19c on OL8

export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_2
mkdir -p ${ORACLE_HOME}
unzip -oq /install/Oracle/Database/19/db/V982063-01.zip -d ${ORACLE_HOME}
unzip -oq /install/Oracle/Database/OPatch/p6880880_190000_Linux-x86-64.zip -d ${ORACLE_HOME}
export CV_ASSUME_DISTID=OL8
#${ORACLE_HOME}/runInstaller -waitforcompletion -silent -responsefile /install/Oracle/Database/19/db/db_install_single_EE.rsp -applyRU /h510tmp/19c/19.24/36582629
#${ORACLE_HOME}/runInstaller -waitforcompletion -silent -responsefile /install/Oracle/Database/19/db/db_install_single_EE.rsp -applyRU /h510tmp/19c/19.27/37641958
${ORACLE_HOME}/runInstaller -waitforcompletion -silent -responsefile /install/Oracle/Database/19/db/db_install_single_EE.rsp -applyRU /h510tmp/19c/19.28/37957391 -applyOneoffs /h510tmp/19c/19.28/37847857
${ORACLE_HOME}/runInstaller -waitforcompletion -silent -responsefile /install/Oracle/Database/19/db/db_install_single_EE.rsp

sudo /u01/app/oraInventory/orainstRoot.sh
sudo ${ORACLE_HOME}/root.sh
${ORACLE_HOME}/bin/roohctl -enable

${ORACLE_HOME}/OPatch/opatch napply -silent -phbasedir /h510tmp/19c/19.24/36414915


# 19.x OL9 Golden Image
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
mkdir -p ${ORACLE_HOME}
#unzip -oq /h510tmp/19c/19.21/db_home_2023-10-25_10-18-34PM.zip -d ${ORACLE_HOME}
#unzip -oq /h510tmp/19c/19.22/db_home_2024-01-17_12-36-37PM.zip -d ${ORACLE_HOME}
unzip -oq /h510tmp/19c/19.27/db_home_2025-04-17_03-24-05PM.zip -d ${ORACLE_HOME}

${ORACLE_HOME}/runInstaller -silent -responsefile /install/Oracle/Database/19/db/db_install_single_EE.rsp
sudo /u01/app/oraInventory/orainstRoot.sh
sudo ${ORACLE_HOME}/root.sh
${ORACLE_HOME}/bin/roohctl -enable


#21c Grid Infrastructure
mkdir -p /u01/app/21.0.0/grid_1
unzip -oq /install/Oracle/Database/21c/V1011504-01.zip -d /u01/app/21.0.0/grid_1

# 21c on OL8

export ORACLE_HOME=/u01/app/oracle/product/21.0.0/dbhome_1
mkdir -p ${ORACLE_HOME}
unzip -oq /install/Oracle/Database/21c/V1011496-01.zip -d ${ORACLE_HOME}
unzip -oq /install/Oracle/Database/OPatch/p6880880_210000_Linux-x86-64.zip -d ${ORACLE_HOME}
#export CV_ASSUME_DISTID=OL7
#${ORACLE_HOME}/runInstaller
${ORACLE_HOME}/runInstaller -silent -responsefile /install/Oracle/Database/21c/db_install_single_EE.rsp
sudo /u01/app/oraInventory/orainstRoot.sh
sudo ${ORACLE_HOME}/root.sh
${ORACLE_HOME}/bin/roohctl -enable

# 26ai on OL9

export ORACLE_HOME=/u01/app/oracle/product/26.0.0/dbhome_1
mkdir -p ${ORACLE_HOME}
unzip -oq /install/Oracle/Database/26ai/LINUX.X64_2326100_db_home.zip -d ${ORACLE_HOME}
#unzip -oq /install/Oracle/Database/OPatch/p6880880_210000_Linux-x86-64.zip -d ${ORACLE_HOME}
${ORACLE_HOME}/runInstaller -silent -responsefile /install/Oracle/Database/26ai/db_install_single_EE.rsp
sudo /u01/app/oraInventory/orainstRoot.sh
sudo ${ORACLE_HOME}/root.sh
${ORACLE_HOME}/bin/roohctl -enable

# 19.14
$ORACLE_HOME/OPatch/opatch napply -silent -phbasefile /h510tmp/19c/19.14/phb1.f
$ORACLE_HOME/OPatch/opatch napply -silent -phbasefile /h510tmp/19c/19.14/phb2.f

# 19.17
$ORACLE_HOME/OPatch/opatch napply -silent -phbasefile /h510tmp/19c/19.17/phb.f

# 19.18
$ORACLE_HOME/OPatch/opatch napply -silent -phbasefile /h510tmp/19c/19.18/phb.f
$ORACLE_HOME/OPatch/opatch napply -silent -phbasefile /h510tmp/19c/19.18/phb0.f
$ORACLE_HOME/OPatch/opatch napply -silent -phbasefile /h510tmp/19c/19.18/phb1.f

# 19.22
$ORACLE_HOME/OPatch/opatch napply -silent -phbasefile /h510tmp/19c/19.22/phb.f
$ORACLE_HOME/OPatch/opatch napply -silent -phbasefile /h510tmp/19c/19.22/phb0.f
$ORACLE_HOME/OPatch/opatch napply -silent -phbasefile /h510tmp/19c/19.22/phb1.f

# 21.9
$ORACLE_HOME/OPatch/opatch napply -silent -phbasefile /h510tmp/21c/21.9/phb.f
# 21.20
$ORACLE_HOME/OPatch/opatch napply -silent -phbasefile /h510tmp/21c/21.20/phb.f


# new db

export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=REPO
mkdir /oradata1/REPO
mkdir -p /u01/app/oracle/admin/REPO/adump
vi /tmp/initREPO.ora


*._disable_highres_ticks=TRUE#VKTM refresh frequency
*._disable_file_resize_logging=TRUE
*.audit_file_dest='/u01/app/oracle/admin/REPO/adump'
*.audit_sys_operations=FALSE
*.audit_trail='NONE'
*.compatible='19.0.0.0.0'
*.control_files='/oradata1/REPO/control01.ctl','/oradata1/REPO/control02.ctl'
*.db_block_size=8192
*.db_name='REPO'
*.db_unique_name='REPO'
*.diagnostic_dest='/u01/app/oracle'
*.event='10795 trace name context forever, level 2','10720 trace name context forever, level 0x10000000'#Disable VKTM, VKRM trace
*.filesystemio_options='setall'
*.open_cursors=300
*.pga_aggregate_target=512M
*.processes=150
*.remote_login_passwordfile='EXCLUSIVE'
*.sga_target=2G
*.undo_tablespace='UNDO'

sqlplus / as sysdba
create spfile from pfile='/tmp/initREPO.ora';
startup nomount


CREATE DATABASE "REPO"
USER SYS IDENTIFIED BY Oracle123
USER SYSTEM IDENTIFIED BY Oracle123
SET DEFAULT BIGFILE TABLESPACE
LOGFILE GROUP 1 ('/oradata1/REPO/redo01.log') SIZE 1G BLOCKSIZE 512,
        GROUP 2 ('/oradata1/REPO/redo02.log') SIZE 1G BLOCKSIZE 512,
        GROUP 3 ('/oradata1/REPO/redo03.log') SIZE 1G BLOCKSIZE 512
MAXLOGHISTORY 1
MAXLOGFILES 16
MAXLOGMEMBERS 3
MAXDATAFILES 1024
CHARACTER SET AL32UTF8
NATIONAL CHARACTER SET AL16UTF16
EXTENT MANAGEMENT LOCAL
DATAFILE '/oradata1/REPO/system.dbf' SIZE 1G REUSE AUTOEXTEND ON NEXT 100M MAXSIZE 4G
SYSAUX DATAFILE '/oradata1/REPO/sysaux.dbf' SIZE 1G REUSE AUTOEXTEND ON NEXT 100M MAXSIZE 4G
DEFAULT TABLESPACE users DATAFILE '/oradata1/REPO/users.dbf' SIZE 100M REUSE AUTOEXTEND ON NEXT 100M MAXSIZE 4G
DEFAULT TEMPORARY TABLESPACE temp TEMPFILE '/oradata1/REPO/temp.dbf' SIZE 100M REUSE AUTOEXTEND ON NEXT 100M MAXSIZE 4G
UNDO TABLESPACE undo DATAFILE '/oradata1/REPO/undo.dbf' SIZE 100M REUSE AUTOEXTEND ON NEXT 100M MAXSIZE 4G
;

@?/rdbms/admin/catalog.sql
@?/rdbms/admin/catproc.sql
@?/rdbms/admin/utlrp.sql
connect system/Oracle123
@?/sqlplus/admin/pupbld.sql
conn / as sysdba
alter profile default limit password_life_time unlimited;
alter user dbsnmp identified by Oracle123 account unlock;
conn / as sysdba

begin
  dbms_auto_task_admin.disable(client_name => 'auto space advisor', operation => null, window_name => null);
  dbms_auto_task_admin.disable(client_name => 'sql tuning advisor', operation => null, window_name => null);
end;
/

DECLARE
filter1 CLOB;
BEGIN
filter1 := DBMS_STATS.CONFIGURE_ADVISOR_RULE_FILTER('AUTO_STATS_ADVISOR_TASK','EXECUTE',NULL,'DISABLE');
END;
/

$ORACLE_HOME/OPatch/datapatch

exec DBMS_OPTIM_BUNDLE.ENABLE_OPTIM_FIXES ('ON', 'SPFILE', 'YES');

# RAC
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=RYRAC19
mkdir /oradata1/RYRAC19
mkdir -p /u01/app/oracle/admin/RYRAC19/adump
vi /tmp/initRYRAC19.ora


*._disable_highres_ticks=TRUE#VKTM refresh frequency
*._disable_file_resize_logging=TRUE
*.audit_file_dest='/u01/app/oracle/admin/RYRAC19/adump'
*.audit_sys_operations=FALSE
*.audit_trail='NONE'
*.compatible='19.0.0.0.0'
*.control_files='+DATA'
*.db_block_size=8192
*.db_create_file_dest='+DATA'
*.db_name='RYRAC19'
*.db_recovery_file_dest='+DATA'
*.db_recovery_file_dest_size=20G
*.diagnostic_dest='/u01/app/oracle'
*.event='10795 trace name context forever, level 2','10720 trace name context forever, level 0x10000000'#Disable VKTM, VKRM trace
*.filesystemio_options='setall'
*.open_cursors=300
*.pga_aggregate_target=512M
*.processes=150
*.remote_login_passwordfile='EXCLUSIVE'
*.sga_target=2G
*.undo_tablespace='UNDO1'

sqlplus / as sysdba
create spfile from pfile='/tmp/initRYRAC19.ora';
startup nomount

CREATE DATABASE RYRAC19
USER SYS IDENTIFIED BY Oracle123
USER SYSTEM IDENTIFIED BY Oracle123
SET DEFAULT BIGFILE TABLESPACE
LOGFILE GROUP 1 SIZE 100M BLOCKSIZE 512,
        GROUP 2 SIZE 100M BLOCKSIZE 512,
        GROUP 3 SIZE 100M BLOCKSIZE 512
MAXLOGHISTORY 1
MAXLOGFILES 16
MAXLOGMEMBERS 3
MAXDATAFILES 1024
CHARACTER SET AL32UTF8
NATIONAL CHARACTER SET AL16UTF16
EXTENT MANAGEMENT LOCAL
DATAFILE SIZE 1G  AUTOEXTEND ON NEXT 100M MAXSIZE 4G
SYSAUX DATAFILE SIZE 1G  AUTOEXTEND ON NEXT 100M MAXSIZE 4G
DEFAULT TABLESPACE users DATAFILE  SIZE 100M  AUTOEXTEND ON NEXT 100M MAXSIZE 4G
DEFAULT TEMPORARY TABLESPACE temp TEMPFILE SIZE 100M  AUTOEXTEND ON NEXT 100M MAXSIZE 4G
UNDO TABLESPACE undo1 DATAFILE SIZE 100M  AUTOEXTEND ON NEXT 100M MAXSIZE 4G
;

@?/rdbms/admin/catalog.sql
@?/rdbms/admin/catproc.sql
@?/rdbms/admin/utlrp.sql
connect system/"Elcaro.135"
@?/sqlplus/admin/pupbld.sql
conn / as sysdba
alter profile default limit password_life_time unlimited;
alter user dbsnmp identified by Oracle123 account unlock;
exit

/u01/app/oracle/product/19.0.0/dbhome_1/OPatch/datapatch


create UNDO TABLESPACE undo2 DATAFILE SIZE 1G AUTOEXTEND ON NEXT 100M MAXSIZE 4G;
create UNDO TABLESPACE undo3 DATAFILE SIZE 1G AUTOEXTEND ON NEXT 100M MAXSIZE 4G;
create UNDO TABLESPACE undo4 DATAFILE SIZE 1G AUTOEXTEND ON NEXT 100M MAXSIZE 4G;

alter database add logfile thread 2 size 100M;
alter database add logfile thread 2 size 100M;
alter database add logfile thread 2 size 100M;
alter database enable thread 2;
alter database add logfile thread 3 size 100M;
alter database add logfile thread 3 size 100M;
alter database add logfile thread 3 size 100M;
alter database enable thread 3;
alter database add logfile thread 4 size 100M;
alter database add logfile thread 4 size 100M;
alter database add logfile thread 4 size 100M;
alter database enable thread 4;
@?/rdbms/admin/catclust


alter system reset undo_tablespace sid='*';
alter system set undo_tablespace='UNDO1' sid='RYRAC191' scope=spfile;
alter system set undo_tablespace='UNDO2' sid='RYRAC192' scope=spfile;
alter system set undo_tablespace='UNDO3' sid='RYRAC193' scope=spfile;
alter system set undo_tablespace='UNDO4' sid='RYRAC194' scope=spfile;
alter system set instance_number=1 sid='RYRAC191' scope=spfile;
alter system set instance_number=2 sid='RYRAC192' scope=spfile;
alter system set instance_number=3 sid='RYRAC193' scope=spfile;
alter system set instance_number=4 sid='RYRAC194' scope=spfile;
alter system set thread=1 sid='RYRAC191' scope=spfile;
alter system set thread=2 sid='RYRAC192' scope=spfile;
alter system set thread=3 sid='RYRAC193' scope=spfile;
alter system set thread=4 sid='RYRAC194' scope=spfile;
alter system set cluster_database=true scope=spfile;


/u01/app/oracle/product/19.0.0/dbhome_1/bin/netca -silent -responsefile /h510tmp/19.6/netca.rsp


begin
  dbms_auto_task_admin.disable(client_name => 'auto space advisor', operation => null, window_name => null);
  dbms_auto_task_admin.disable(client_name => 'sql tuning advisor', operation => null, window_name => null);
end;
/

DECLARE
filter1 CLOB;
BEGIN
filter1 := DBMS_STATS.CONFIGURE_ADVISOR_RULE_FILTER('AUTO_STATS_ADVISOR_TASK','EXECUTE',NULL,'DISABLE');
END;
/


rman target /
CONFIGURE BACKUP OPTIMIZATION ON;
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '/oracle_backup/REPO/%F';
CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT   '/oracle_backup/REPO/%U';

RYSAM19 =
 (DESCRIPTION = 
   (ADDRESS_LIST =
     (ADDRESS = (PROTOCOL = TCP)(HOST = o82.balazs.vm)(PORT = 1521))
   )
 (CONNECT_DATA =
   (SERVICE_NAME = RYSAM19)
 )
)

@mksample Oracle123 Oracle123 hrpw oepw pmpw ixpw shpw bipw users temp /home/oracle/db-sample-schemas-19.2/log rysam19


Bug 31969830 - 'semanage' Binary Required Due To SELinux Fix in Bug 30041206 (Doc ID 31969830.8)

dnf install policyREPOutils-python-utils -y


exec DBMS_OPTIM_BUNDLE.ENABLE_OPTIM_FIXES ('ON', 'SPFILE', 'YES');
