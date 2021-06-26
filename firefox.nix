{ config, pkgs, ... }:

let

  hardenedFirefox = pkgs.wrapFirefox pkgs.firefox-unwrapped {
     nixExtensions = with pkgs; [
        (fetchFirefoxAddon {
          name = "ublock";
          url = "https://addons.mozilla.org/firefox/downloads/file/3768975/ublock_origin-1.35.2-an+fx.xpi";
          sha256 = "0x9rihigl0fqjpjykwh2lg9ga3zx9g58sqmrvn8jp1f5dd1zmk4f";
        })
        (fetchFirefoxAddon {
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

    forceWayland = false;
  };

in {

environment.variables = {
  BROWSER = ["firefox"];
};

environment.systemPackages = with pkgs; [
  hardenedFirefox
];

}
