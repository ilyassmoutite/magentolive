node {
    DEV_SERVER="ilyass@192.168.1.120"
    STAGE_SERVER="<user>@<host>"
    PROD_SERVER="<user>@<host>"

 	// Clean workspace before doing anything
    deleteDir()

    try {
        stage ('Clone') {
        	checkout scm
        }
        stage ('Install') {
        	echo "composer install skipped"
        }
        stage ('Tests') {
            sh "echo 'shell scripts to create DB and settings for integration tests'"
	        parallel 'static': {
	            sh "echo 'shell scripts to run static tests...'"
	        },
	        'unit': {
	            sh "echo 'shell scripts to run unit tests...'"
	        },
	        'integration': {
	            sh "echo 'shell scripts to run integration tests...'"
	        }
        }
        branchInfo = getBranchInfo()
        stage ('Artifact') {
            artifactFilename = "/tmp/${branchInfo.version}.tar.gz"
		sh "pwd"
            sh "ARTIFACT_FILENAME=${artifactFilename} ./build.sh"
        }
        if (branchInfo.type == 'develop') {
      	    stage ('Deploy DEV') {
      	         sh "scp -P 22 -o StrictHostKeyChecking=No ${artifactFilename} ${DEV_SERVER}:downloads"
                 sh "ssh -p 22 -o StrictHostKeyChecking=No ${DEV_SERVER} 'VERSION=${branchInfo.version} ./deploy.sh'"
      	    }
      	}
      	if (branchInfo.type == 'release' || branchInfo.type == 'hotfix') {
      	    stage ('Confirm Deploy') {
                confirmedServer = confirmServerToDeploy()
            }
            if (confirmedServer) {
                stage ('Tag Version') {
                    commitId = getCommitSha()
                    sh "git remote set-branches --add origin master && git remote set-branches --add origin develop && git fetch"
                    sh "git checkout develop && git merge ${commitId} && git push"
                    sh "git checkout master && git merge ${commitId} && git push"
                    sh "git tag ${branchInfo.version} && git push --tags"
                }
                if (confirmedServer in ['stage','both']) {
                    stage ('Deploy STAGE') {
                        sh "scp -P 22 -o StrictHostKeyChecking=No ${artifactFilename} ${STAGE_SERVER}:downloads"
                        sh "ssh -p 22 -o StrictHostKeyChecking=No ${STAGE_SERVER} 'VERSION=${branchInfo.version} ./deploy.sh'"
                    }
                }
                if (confirmedServer in ['production','both']) {
                    stage ('Deploy PROD') {
                        sh "scp -P 22 -o StrictHostKeyChecking=No ${artifactFilename} ${PROD_SERVER}:downloads"
                        sh "ssh -p 22 -o StrictHostKeyChecking=No ${PROD_SERVER} 'VERSION=${branchInfo.version} ./deploy.sh'"
                    }
                }
            }
        }
      	stage ('Clean Up') {
      	    sh "rm -rf ${artifactFilename}"
            deleteDir()
        }
    } catch (err) {
        currentBuild.result = 'FAILED'
        // Send email or another notification
        throw err
    }
}

def getBranchInfo() {
    def branchInfo = [:]
    branchData = BRANCH_NAME.split('/')
    if (branchData.size() == 2) {
        branchInfo['type'] = branchData[0]
        branchInfo['version'] = branchData[1]
    } else {
        branchInfo['type'] = BRANCH_NAME
        branchInfo['version'] = BRANCH_NAME
    }
    return branchInfo
}

def confirmServerToDeploy() {
    def server = false
    try {
        timeout(time:2, unit:'HOURS') {
            server = input(
                id: 'environmentInput', message: 'Deployment Settings', parameters: [
                choice(choices: "stage\nproduction\nboth", description: 'Target server to deploy', name: 'deployServer')
            ])
        }
    } catch (err) {
        echo "Timeout expired. Environment was not set by user"
    }
    return server
}

def getCommitSha(){
    return sh(returnStdout: true, script: 'git rev-parse HEAD')
}

