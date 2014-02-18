inviteListEvent
===

    emailRegEx = @emailRegEx = /[a-z0-9!#$%&'*+/=?^_{|}~-]+(?:.[a-z0-9!#$%&'*+/=?^_{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+(?:[A-Z]{2}|com|org|net|gov|mil|edu|biz)\b/

    processNewEmail = @processNewEmail = (i)->
       if emailRegEx.test i
                  existing = emailCSVs.findOne { email: i }
                  if existing?
                      b3.flashError 'Previously existing email: '+i, { single: 'previouslyExistingEmail' }
                      return
                  doc = {}
                  doc.user = Meteor.userId()
                  doc.email = i
                  doc.invited = false
                  doc.group = 'ungrouped'
                  previous = Meteor.users.findOne { emails: { $elemMatch: { address: i }}}
                  if previous?
                      doc.registered = true
                  else
                      doc.registered = false

                  emailCSVs.insert doc
        else
            if i is "" then return
            b3.flashError 'invalid email: '+i, { single: 'invalidEmail' }

    inviteListEvent = @inviteListEvent = (event)->
        fileInput = document.querySelector('input[type=file]')
        file = fileInput.files[0]
        reader = new FileReader
        reader.readAsText file
        result = []
        reader.onload = (e)-> 
          results = csvToArray e.target.result
          results.forEach (r)->
            r.forEach (i)->
                processNewEmail i
       
