Config = {
    webhook = "https://discord.com/api/webhooks/1236125257006452888/MVGyRjq4JF7zmWNKU1IUPxaZ9KShHPjCcuDDPT4dDfSOsWGNb8kEkLSvkicWa5eQ645z", -- Paste Discord Webhook URL here to receive messages in a discord channel about submited whitelist applications
    UseTarget = GetConvar('UseTarget', 'false') == 'true', -- Use qb-target interactions (don't change this, go to your server.cfg and add `setr UseTarget true` to use this and just that from true to false or the other way around)
    useImages = true, -- If set to false the jobs won't have images
    useFxTextUI = true, -- Whether or not to use our free script fxTextUI (Otherwise will use default qb) 
    useFxNotify = true, -- Whether or not to use our free script fxNotify (Otherwise will use default qb)
    whitelistCooldown = 24, -- The cooldown period, in hours, during which players can apply exclusively to whitelist jobs(each job has it's own seperate cooldown) before being able to apply again
    closeWhitelistApplications = false, -- When set to true the whitelist tab won't be accesible

    Locations = {
        {
            coords = vector3(-262.79, -964.18, 30.22),
            npcHeading = 181.71,
            ped = 's_m_m_movprem_01',
            scenario = 'WORLD_HUMAN_GUARD_STAND_FACILITY',
            showBlip = true,
            zoneOptions = { -- Used for when UseTarget is false
                length = 3.0,
                width = 3.0,
                debugPoly = false
            },
            blipData = {
                sprite = 498,
                display = 4,
                scale = 0.65,
                colour = 7,
                title = Lang:t('info.blip_text')
            }
        }
    },

    Jobs = {
        Whitelist = {
            {
                jobLabel = 'Police Department',
                jobDescription = 'Join the force to serve and protect, ensuring public safety and upholding the law.',
                jobName = 'police',
                questions = {
                     'How old are you in real life?',
                     'Have you worked in law enforcement before? If yes, in which servers, at what stage of the process, and for how long?',
                     'What steps would you take if you encounter a suspect resisting arrest?',
                     'How would you handle a situation where you suspect someone is carrying illegal substances?',
                     'How do you approach diffusing a tense situation between two individuals?',
                    'What measures would you take to ensure public safety during a large-scale event?',
                }
            },
            {
                jobLabel = 'Medical Department',
                jobDescription = 'Provide crucial medical care in emergency situations, saving lives and promoting public health.',
                jobName = 'ambulance',
                questions = {
                    'How old are you in real life?',
                    'Have you worked in a medical role before? If yes, in which servers, at what capacity, and for how long?',
                    'How would you prioritize patient care during a mass casualty incident?',
                     'What steps would you take to handle a medical emergency in a remote location?',
                    'How do you communicate effectively with patients who may be in distress or pain?',
                    'What precautions would you take to prevent the spread of infectious diseases within a medical facility?',
                }
            },
            {
                jobLabel = 'Mechanic',
                jobDescription = 'Maintain and repair vehicles, ensuring they run smoothly and efficiently for everyday use.',
                jobName = 'mechanic',
                questions = {
                    'How old are you in real life?',
                    'Have you worked as a mechanic before? If yes, in which servers, at what level, and for how long?',
                    'How would you diagnose and repair a vehicle with an unknown issue?',
                    'What steps would you take to handle a customer who is dissatisfied with a repair job?',
                    'How do you prioritize tasks when there are multiple vehicles awaiting repairs?',
                    'How would you handle a situation where a vehicle breaks down on a busy highway?',
                }
            },
            {
                jobLabel = 'Taxi',
                jobDescription = 'Provide transportation services to passengers, driving them to their destinations safely and efficiently.',
                jobName = 'taxi',
                questions = {
                    'How old are you in real life?',
                    'Have you worked as a taxi driver before? If yes, in which servers, and for how long?',
                    'How would you handle a situation where a passenger becomes aggressive or refuses to pay the fare?',
                    'What steps would you take to ensure the cleanliness and comfort of your taxi for passengers?',
                    'How do you navigate to a destination efficiently, especially during peak traffic hours?',
                    'How would you handle a request for an urgent trip to the hospital or emergency services?',
                }
            },
        },
        NonWhitelist = {
            {
                jobLabel = 'Unemployed',
                jobDescription = 'Currently without employment, seeking opportunities to work and contribute to the community.',
                jobName = 'unemployed'
            },
            {
                jobLabel = 'Towing',
                jobDescription = 'Tow vehicles, helping to maintain traffic flow and safety on the roads.',
                jobName = 'tow'
            },
            {
                jobLabel = 'Trucker',
                jobDescription = 'Transport goods and materials across long distances, ensuring timely delivery and distribution.',
                jobName = 'trucker'
            },
            {
                jobLabel = 'Hotdog Stand',
                jobDescription = 'Operate a food stand selling hotdogs, providing quick and tasty meals to customers.',
                jobName = 'hotdog'
            },
            {
                jobLabel = 'Reporter',
                jobDescription = 'Investigate and report on news events, informing the public about current affairs and happenings.',
                jobName = 'reporter'
            },
            {
                jobLabel = 'Garbage Collector',
                jobDescription = 'Collect and dispose of garbage and recycling materials, keeping the streets clean and sanitary.',
                jobName = 'garbage'
            },
            {
                jobLabel = 'Bus Driver',
                jobDescription = 'Operate a bus to transport passengers along designated routes.',
                jobName = 'bus'
            }
        }
    }
}
