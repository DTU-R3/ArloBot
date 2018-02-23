const personalData = require('./personalData');
const fs = require('fs');
const exec = require('child_process').exec;
const say = require('say');
const push = require('pushover-notifications');

function tts(sound) {

    // This will not make any noise if the file
    // ~/.arlobot/status/bequiet
    // exists
    const beQuietFile = process.env.HOME + '/.arlobot/status/bequiet';
    fs.open(beQuietFile, 'r', function (err) {
        if (err) {
            console.log(sound);

            // Set volume at max
            const setVolumeCommand = '/usr/bin/amixer set Master ' + personalData.speechVolumeLevelDefault + '% on';
            exec(setVolumeCommand);

            // Turn on external speaker if off and plugged in
            //   At least this will help keep it charged. ;)
            // if (personalData.use_external_speaker && personalData.useMasterPowerRelay && personalData.relays.has_fiveVolt && webModel.pluggedIn && webModel.relays.find(x=> x.name === 'fiveVolt') && !webModel.relays.find(x=> x.name === 'fiveVolt')['relayOn'] && !robotModel.master.isAsleep) {
            //     if (!webModel.masterRelayOn) {
            //         const masterRelay = require('./MasterRelay');
            //         masterRelay('on');
            //     }
            //     const UsbRelay = require('./UsbRelayControl');
            //     const usbRelay = new UsbRelay();
            //     if (webModel.relays.find(x=> x.name === 'fiveVolt') && !webModel.relays.find(x=> x.name === 'fiveVolt')['relayOn']) {
            //         usbRelay.switchRelay(webModel.relays.find(x=> x.name === 'fiveVolt')['number'],'on');
            //     }
            // }

            // This script can accept text to speak,
            // or .wav files to play.
            // We rely stricly on the extension to
            // decide what it is!
            const possibleExtension = sound.slice(-4).toLowerCase();
            if (possibleExtension === '.wav') {
                exec('/usr/bin/mplayer -quiet ' + sound + ' > /dev/null 2>&1');
            } else {
                if (personalData.speechProgram === 'nodeSay') {
                    // https://github.com/marak/say.js/
                    // no callback, fire and forget
                    say.speak(sound);
                } else if (personalData.speechProgram) {
                    exec(`${personalData.speechProgram} "${sound}"`);
                }
            }
        } else {
            // Log to console and web if we are force to be quiet
            console.log(sound);
        }
    });
    // Send 'sound' to myself via Pushover
    if (personalData.pushover.USER !== "" && sound !== '' && sound !== undefined && sound !== null) {
        const p = new push({
            user: personalData.pushover.USER,
            token: personalData.pushover.TOKEN
        });
        const msg = {
            message: sound,
            sound: personalData.pushover.sound,
            priority: -1
        };
        p.send(msg); // Silent with no error reporting
    }
}

module.exports = tts;

if (require.main === module) {
    if (process.argv.length < 3) {
        console.log("You must provide text for the message, like this:");
        console.log(`node tts.js "test message"`);
        process.exit();
    }
    tts(process.argv[2]);
}
