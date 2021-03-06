const fs = require('fs');
const getRobotDataFromWeb = require('./getRobotDataFromWeb').getRobotDataFromWeb;

const getEtcHostsFile = async function () {
    return new Promise((resolve, reject) => {
        fs.readFile('/etc/hosts', 'utf8', (err, data) => {
            if (err) {
                reject(err);
            } else {
                resolve(data);
            }
        });
    })
};

const writeNewEtcHostsFile = async function (data) {
    return new Promise((resolve, reject) => {
        fs.writeFile('/etc/hosts', data, (err, data) => {
            if (err) {
                reject(err);
            } else {
                resolve(data);
            }
        })
    })
};

const addRobotIpToEtcHosts = async function () {
    try {
        const robotData = await getRobotDataFromWeb();
        const etcHosts = await getEtcHostsFile();
        const etcHostsArray = etcHosts.split('\n');
        let newEtcHostsArray = [];
        let alreadyThere;
        etcHostsArray.forEach(line => {
            if (line.slice(0, 1) === '#') {
                // Don't check comments, just include them.
                newEtcHostsArray.push(line);
            } else if (line.split(/\s/)[1] === robotData.robotHostname) {
                // If the line contains the hostname, but not the right IP,
                // Then it is excluded
                if (line.split(/\s/)[0] === robotData.robotIP) {
                    alreadyThere = true;
                    newEtcHostsArray.push(line);
                }
            } else {
                // Include everything else in the file too.
                newEtcHostsArray.push(line);
            }
        });
        if (!alreadyThere) {
            newEtcHostsArray.push(`${robotData.robotIP}\t${robotData.robotHostname}`);

            /// Put the trailing newline back
            newEtcHostsArray.push('');

            const newEtcHostsData = newEtcHostsArray.join('\n');

            await writeNewEtcHostsFile(newEtcHostsData);
        }
        return (null);
    } catch (e) {
        return (e);
    }
};
exports.addRobotIpToEtcHosts = addRobotIpToEtcHosts;

if (require.main === module) {
    // Run the function if this is called directly instead of required.
    (async function () {
        const error = await addRobotIpToEtcHosts();
        if (error) {
            console.log(error);
            process.exit(1);
        }
    })();
}
