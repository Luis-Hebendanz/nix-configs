{ config, pkgs, ... }:

let
  fetchfirefoxaddon= callPackage ./modules/fetchfirefoxaddon {};
  callPackage = pkgs.unstable.pkgs.lib.callPackageWith (pkgs.unstable.pkgs);
  wrapper =  callPackage ./overlays/wrapper.nix { lndir=pkgs.xorg.lndir; };

  hardenedFirefox= wrapper pkgs.unstable.pkgs.firefox-unwrapped {
     nixExtensions = [
        (fetchfirefoxaddon {
          name = "ublock";
          url = "https://addons.mozilla.org/firefox/downloads/file/3679754/ublock_origin-1.31.0-an+fx.xpi";
          sha256 = "1h768ljlh3pi23l27qp961v1hd0nbj2vasgy11bmcrlqp40zgvnr";
        })
        (fetchfirefoxaddon {
           name = "certificate-pinner";
           url = "https://addons.mozilla.org/firefox/downloads/file/3599612/certificate_pinner-0.17.10-an+fx.xpi";
           sha256 = "15qyjqca252pf28vv636fwya28pj3nnbywpkpm6cwmj1m64pmdsl";
         })
     ];

    extraPolicies = {
      CaptivePortal = false;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisableFirefoxAccounts = true;
      FirefoxHome = {
        Pocket = false;
        Snippets = false;
      };
       UserMessaging = {
         ExtensionRecommendations = false;
         SkipOnboarding = true;
       };
    };

    extraPrefs = ''
      // Show more ssl cert infos
      lockPref("security.identityblock.show_extended_validation", true);

      // Enable userchrome css
      lockPref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

      // Enable dark dev tools
      lockPref("devtools.theme","dark");

      // Disable js in PDFs
      lockPref("pdfjs.enableScripting", false);
    '';

    forceWayland = true;
  };

in {

environment.variables = {
  BROWSER = ["firefox"];
};

environment.systemPackages = with pkgs; [
  # pkgs.unstable.pkgs.firefox
  hardenedFirefox
];

}
