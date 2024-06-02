window.addEventListener('message', function(event) {
    if (event.data.action == 'openJobCenter') {
        const useImages = event.data.useImages;
        const clickSound = new Audio('click-sfx.wav');
        document.body.innerHTML = `
        <div class="main-container">
            <div class="nav-bar">
                <img src="fx_logo.png" class="fx-logo"></img>
                <div class="text-container">Job Center</div>
                <div class="allButton" id="btn">All</div>
                <div class="whitelistButton" id="btn">Whitelist</div>
                <div class="nonWhitelistButton" id="btn">Non Whitelist</div>
                <div class="exit-container">
                    <button class="exit-button">Exit</button>
                    <span>ESC</span>
                </div>
            </div>
            <div class="lower-container"></div>
        </div>`;

        setTimeout(() => {
            document.querySelector('.main-container').classList.add('show');
        }, 10);
        
        const allButton = document.querySelector('.allButton');
        const whitelistButton = document.querySelector('.whitelistButton');
        const nonWhitelistButton = document.querySelector('.nonWhitelistButton');
        const lowerContainer = document.querySelector('.lower-container');

        function selectButton(button) {
            allButton.classList.remove('selected');
            whitelistButton.classList.remove('selected');
            nonWhitelistButton.classList.remove('selected');

            button.classList.add('selected');
            clickSound.play();
            addJoinButtonEventListeners();
        }

        let allJobs;

        if (event.data.closeWhitelistApplications) {
            allJobs = event.data.nonWhitelistJobs.map(job => ({ ...job, isWhitelist: false }));
        } else {
             allJobs = event.data.whitelistJobs.concat(event.data.nonWhitelistJobs).map(job => ({
                ...job,
                isWhitelist: event.data.whitelistJobs.includes(job)
            }));
        }
        const whitelistJobs = event.data.whitelistJobs.map(job => ({ ...job, isWhitelist: true }));
        const nonWhitelistJobs = event.data.nonWhitelistJobs.map(job => ({ ...job, isWhitelist: false }));
        let allJobsHTML = '';
        let whitelistJobsHTML = '';
        let nonWhitelistJobsHTML = '';

        function generateJobHTML(jobs) {
            let jobHTML = '';
            jobs.forEach(function(job) {
                let imageSrc = useImages ? `${job.jobName}-image.jpg` : '';
                let buttonText = job.isWhitelist ? 'Request to Join' : 'Join';
                jobHTML += `
                <div class="job-container" data-job-name="${job.jobName}" data-job-label="${job.jobLabel}">
                    <img src="${imageSrc}" alt="" class="job-image">        
                    <h1>${job.jobLabel}</h1>        
                    <div class="description">
                        <p>${job.jobDescription}</p>
                    </div>
                    <div class="join-button">${buttonText}</div>
                </div>
                `;
            });
            return jobHTML;
        }

        allJobsHTML = generateJobHTML(allJobs);
        whitelistJobsHTML = generateJobHTML(whitelistJobs);
        nonWhitelistJobsHTML = generateJobHTML(nonWhitelistJobs);

        lowerContainer.innerHTML = allJobsHTML;
        addJoinButtonEventListeners();
        selectButton(allButton);

        allButton.addEventListener('click', function() {
            lowerContainer.innerHTML = allJobsHTML;
            selectButton(allButton);
            fadeInLowerContainer();
            setTimeout(jobContainersAnimation, 300);
        });

        if (event.data.closeWhitelistApplications) {
            whitelistButton.style.textDecoration = "line-through";
            whitelistButton.classList.add('disabled');
        } else {
            whitelistButton.addEventListener('click', function() {
                lowerContainer.innerHTML = whitelistJobsHTML;
                selectButton(whitelistButton);
                fadeInLowerContainer();
                setTimeout(jobContainersAnimation, 300);
            });
        }

        function handleDisabledButtonClick(event) {
            event.preventDefault();
            event.stopPropagation();
        }

        if (whitelistButton.classList.contains('disabled')) {
            whitelistButton.addEventListener('click', handleDisabledButtonClick);
        }

        nonWhitelistButton.addEventListener('click', function() {
            lowerContainer.innerHTML = nonWhitelistJobsHTML;
            selectButton(nonWhitelistButton);
            fadeInLowerContainer();
            setTimeout(jobContainersAnimation, 300);
        });

        function addJoinButtonEventListeners() {
            const joinButtons = document.querySelectorAll('.join-button');
            joinButtons.forEach((joinButton) => {
                if (!joinButton.hasEventListener) {
                    joinButton.hasEventListener = true;
                    joinButton.addEventListener('click', function() {
                        const jobName = joinButton.parentElement.getAttribute('data-job-name');
                        const jobLabel = joinButton.parentElement.getAttribute('data-job-label');
                        const job = whitelistJobs.find(job => job.jobName === jobName);
                        if (!job) {
                            $.post(`https://${event.data.resourceName}/applyJob`, JSON.stringify(jobName));
                            handleExitButtonClick();
                        } else {
                            const formHTML = `
                            <div class="form">
                                <div class="gradient">
                                    <h1>REQUEST TO JOIN</h1>
                                    <div class="questions">
                                        ${job.questions.map((question, index) => `
                                        <div class="q">
                                            <h2>${index + 1}. ${question}</h2>
                                            <textarea name="q${index + 1}" id="q${index + 1}"></textarea>
                                        </div>`).join('')}
                                        <div class='buttons-container'>
                                            <div class='cancel-btn'>Cancel</div>
                                            <div class='submit-btn'>Submit</div>
                                        </div>
                                    </div>
                                </div>
                            </div>`;
            
                            document.querySelector('.main-container').classList.remove('show');

                            setTimeout(() => {
                                document.body.innerHTML = formHTML;

                                setTimeout(() => {
                                    document.querySelector('.form').classList.add('show');
                                }, 20);

                                const cancelButton = document.querySelector('.cancel-btn');
                                const submitButton = document.querySelector('.submit-btn');
                                
                                cancelButton.addEventListener('click', function() {
                                    handleExitButtonClick();
                                });

                                submitButton.addEventListener('click', function() {
                                    const questionAnswers = [];
                                    const questionElements = document.querySelectorAll('.q');
                                    questionElements.forEach((questionElement, index) => {
                                        const questionText = questionElement.querySelector('h2').innerText;
                                        const textarea = questionElement.querySelector('textarea');
                                        const answer = textarea.value.trim();
                                        questionAnswers.push({ question: questionText, answer: answer });
                                    });
                                    $.post(`https://${event.data.resourceName}/discord`, JSON.stringify({ job: jobName, applyingJob: jobLabel.toString(), qAnswers: questionAnswers }));
                                    handleExitButtonClick();
                                });
                            }, 450);                                    
                        }
                    });
                }
            });
        }

        function fadeInLowerContainer() {
            lowerContainer.style.opacity = '0';
            setTimeout(() => {
                lowerContainer.style.opacity = '1';
            }, 100);
        }
        fadeInLowerContainer();

        function jobContainersAnimation() {
            const jobContainers = document.querySelectorAll('.job-container');
            jobContainers.forEach((container, index) => {
                setTimeout(() => {
                    container.classList.add('loaded');
                }, index * 300); 
            });
        }
        setTimeout(jobContainersAnimation, 300);

        function handleExitButtonClick() {
           $(document.body).fadeOut(300);
           setTimeout(() => {
                document.body.innerHTML = '';
                $(document.body).fadeIn(1);
                $.post(`https://${event.data.resourceName}/close`, JSON.stringify());
            }, 300); 
        }

        const exitButton = document.querySelector('.exit-button');
        exitButton.addEventListener('click', handleExitButtonClick);

        document.addEventListener('keydown', (event) => {
            if (event.key === 'Escape' || event.key === 'Esc') {
                handleExitButtonClick();
            }
        });
    }
});
