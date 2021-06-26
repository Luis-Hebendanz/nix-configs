{ config, pkgs, ... }:
let
  dest = "restic.gchq.icu";
  dest_user = "thinkpad-backup";
  repo-path = "thinkpad-repo";
  port = "7171";

  # NOTE:
  # You have to connect to the machine at least once manually as root to
  # accept the rsa key!

in {
  services.restic.backups.thinkpad =
  {
    initialize = true;
    paths = [ "/home/${config.mainUser}" "${config.secrets}" "/etc/nixos" "/var/lib/iwd"];
    user = "root";
    extraOptions = [ "sftp.command='ssh -p ${port} ${dest_user}@${dest} -i ${config.secrets}/restic/restic_keys -s sftp'" ];
    repository = "sftp:${dest_user}@${dest}:/home/${dest_user}/${repo-path}";
    passwordFile = "${config.secrets}/restic/thinkpad.pwd";
    extraBackupArgs = [ "--exclude '${config.mainUser}/VirtualBox VMs'" "--exclude '${config.mainUser}/Iso'" "--exclude '${config.mainUser}/.cache'" ];
    timerConfig = { OnCalendar = "0/5:00:00"; }; # Backup every 5 hours
  };


}
