local Translations = {
    error = {
        not_in_range = 'Too far from the job center'
    },
    info = {
        new_job_app = 'Your application was sent to the boss of %{job}',
        blip_text = 'Job Center',
        job_center_menu = '[E] Open Job Center',
        new_job = 'Congratulations with your new job! (%{job})',
        target_label = "Open Job Center",
        cooldown = 'You must wait %{time} hours before applying again.',
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
