def OSList = [
    ['Ubuntu 24.04 (amd64)', 'ubuntu-24-amd64', 'docker && linux-amd64'],
    ['RHEL 9 (x86_64)',      'rhel-9-x86_64',   'docker && linux-amd64'],
    ['Debian 12 (amd64)',    'debian-12-amd64', 'docker && linux-amd64'],
    ['Windows (x64)',        'windows-x64',     'docker && linux-amd64'],
    ['MacOSX (brew)',        'macosx-brew',     'macosx'],
    ['MacOSX (macports)',    'macosx-macports', 'macosx'],
]

def setupStage() {
    return {
        stage("Setup") {
            echo "Building on ${NODE_NAME}"
            
            // Useful for debugging
            sh 'printenv'
            
            // This shouldn't be needed, but just in case
            cleanWs disableDeferredWipeout: true, deleteDirs: true
            
            unstash 'source'
        }
    }
}

def testStage(os) {
    return {
        stage("Build & Test") {
            try {
                sh "deploy/build.py -j --os=${os} --build --test -DCMAKE_BUILD_TYPE=Debug --output-junit --dockernetwork=jenkins-${EXECUTOR_NUMBER}"
            }
            finally {
                junit skipPublishingChecks: true, testResults: "workspace-${os}/mdsplus-junit.xml", keepLongStdio: true
            }
        }
    }
}

def packageStage(os) {
    return {
        stage("Build & Package") {
            sh "deploy/build.py -j --os=${os} --build --package -DCMAKE_BUILD_TYPE=Release"
            dir("workspace-${os}/packages") {
                sh "ls"
                stash includes: "*", name: "packages-${os}"
            }
        }
    }
}

def cleanStage() {
    return {
        stage("Clean") {
            // Collect valgrind core dumps
            archiveArtifacts artifacts: "**/core", followSymlinks: false, allowEmptyArchive: true
            
            cleanWs disableDeferredWipeout: true, deleteDirs: true
        }
    }
}

def distributions = OSList.collectEntries {
    info -> [ "${info[0]}": {
        def (name, os, label) = info
        
        node (label) {
            stage(name) {
                ansiColor('xterm') {
                    try {
                        setupStage().call()
                        testStage(os).call()
                        packageStage(os).call()
                    }
                    finally {
                        cleanStage().call()
                    }
                }
            }
        }
    }]
}

def localTest(name, testStages) {
    return {
        stage(name) {
            node('linux-amd64') { // TODO: Improve
                ansiColor('xterm') {
                    try {
                        setupStage().call()
                        
                        stage("Build") {
                            sh "deploy/build.py -j --build --install -DCMAKE_BUILD_TYPE=Debug"
                        }
                        
                        testStages.call()
                    }
                    finally {
                        cleanStage().call()
                    }
                }
            }
        }
    }
}

distributions['IDL'] = localTest('IDL', {
    stage("Test") {
        try {
            withEnv(["MDSPLUS_DIR=${WORKSPACE}/workspace/install/usr/local/mdsplus"]) {
                sh """
                    set +x
                    . \$MDSPLUS_DIR/setup.sh
                    export PYTHONPATH=\$MDSPLUS_DIR/python/
                    set -x
                    ./idl/testing/run_tests.py
                """
            }
        }
        finally {
            junit skipPublishingChecks: true, testResults: "mdsplus-junit.xml", keepLongStdio: true
        }
    }
})

distributions['MATLAB'] = localTest('MATLAB', {
    stage("Test") {
        withEnv(["MDSPLUS_DIR=${WORKSPACE}/workspace/install/usr/local/mdsplus"]) {
            sh """
                set +x
                . \$MDSPLUS_DIR/setup.sh
                export PYTHONPATH=\$MDSPLUS_DIR/python/
                set -x
                echo "Testing MATLAB"
            """
        }
    }
})

pipeline {
    agent {
        label 'built-in'
    }
    
    stages {
        
        stage('Setup') {
            steps {
                sh 'printenv'
                
                retry(3) {
                    checkout scm;
                    // By default it excludes .git/
                    stash name: 'source', includes: '**', useDefaultExcludes: false
                }
            }
        }
        
        stage('Distributions') {
            steps {
                script {
                    parallel distributions
                }
            }
        }
        
        stage('Test Stash') {
            steps {
                script {
                    for (info in OSList) {
                        def (name, os, label) = info
                        unstash "packages-${os}"
                    }
                    
                    sh "ls"
                    
                    archiveArtifacts artifacts: "*.tgz,*.exe", followSymlinks: false
                    
                    cleanWs disableDeferredWipeout: true, deleteDirs: true
                }
            }
        }
    
    }
    
    post {
        failure {
            // if alpha/stable
            mail subject: 'Build is failing',
                body: "Build is failing: ${BUILD_URL}",
                to: 'slwalsh@psfc.mit.edu,heidcamp@mit.edu'
        }
    }

}