http://docs.oracle.com/cd/E73210_01/EMADV/GUID-598AFBE9-F231-4138-A8F0-61A49723127F.htm

/opt/oracle/base/agent/agent_13.4.0.0.0/perl/bin/perl /opt/oracle/base/agent/agent_13.4.0.0.0/sysman/install/AgentDeinstall.pl -agentHome /opt/oracle/base/agent/agent_13.4.0.0.0

/opt/oracle/base/mw13200/bin/emcli login -username=sysman

/opt/oracle/base/mw13200/bin/emcli delete_target -name="o77.balazs.vm:3872" -type="oracle_emd" -delete_monitored_targets
/opt/oracle/base/mw13200/bin/emcli delete_target -name="o78.balazs.vm:3872" -type="oracle_emd" -delete_monitored_targets


/u01/app/oracle/agent/agent_13.3.0.0.0/perl/bin/perl /u01/app/oracle/agent/agent_13.3.0.0.0/sysman/install/AgentDeinstall.pl -agentHome /u01/app/oracle/agent/agent_13.3.0.0.0
/u01/app/oracle/agent/agent_13.4.0.0.0/perl/bin/perl /u01/app/oracle/agent/agent_13.4.0.0.0/sysman/install/AgentDeinstall.pl -agentHome /u01/app/oracle/agent/agent_13.4.0.0.0
/app/oracle/cc13c/agent_aws/agent_13.4.0.0.0/perl/bin/perl /app/oracle/cc13c/agent_aws/agent_13.4.0.0.0/sysman/install/AgentDeinstall.pl -agentHome //app/oracle/cc13c/agent_aws/agent_13.4.0.0.0