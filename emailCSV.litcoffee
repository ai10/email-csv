emailCSV
===


    emailCSVs = @emailCSVs = new Meteor.Collection 'emailCSVs'


    if Meteor.isServer
        Meteor.methods
            sendInvitation: (to, from, subject, text) ->
                check [to, from, subject, text], [String]
                #let other method calls from the same client run
                @unblock()

                Email.send
                    to: to
                    from: from
                    subject: subject
                    text: text

                true


        emailCSVs.allow
          insert: (userId, doc) ->
              doc.user is userId
          remove: (userId, doc) ->
              doc.user is userId
          update: (userId, doc) ->
              doc.user is userId

        Meteor.publish 'emailCSVs', ->
            id = @userId
            emailCSVs.find { user: id }



    if Meteor.isClient
        Meteor.subscribe 'emailCSVs'


