invite List controller
===


    class @InviteListController extends RouteController
      template: 'inviteList'
      run: ->
        super


    Template.inviteList.nongroupedEmails = ->
        m = emailCSVs.find({ group: 'none'})

    Template.inviteList.groups = ->
        g = emailCSVs.find().fetch()
        gg = _.groupBy g, 'group'
        gk = _.keys gg
        ungroupedIndex = gk.indexOf 'ungrouped'
        unless ungroupedIndex is -1
            gk.splice(ungroupedIndex, 1)
            gk.unshift 'ungrouped'
        _.map gk, (k)->
            { key: k }

    Template.inviteList.removeSign = (group)->
        if group is 'ungrouped'
            return 'glyphicon-remove-sign text-danger'
        else
            return 'glyphicon-arrow-left text-warning'

    Template.inviteList.getColor = (field)->
        if field is true then return 'text-success'
        if field is false then return 'text-warning'
        if field is 'ungrouped' then return 'text-warning'
        'text-info'

    Template.inviteList.emails = (group)->
        g = emailCSVs.find({group: group}).fetch()

    regroupName = ""
    newgroupName = ""
    newEmailAddress = ""
    invitationHeader = 'Invitation to ultrasoundLearn.'
    invitationText = 'Sign up for ultrasoundLearn at http://ultrasoundLearn.meteor.com'
    Template.inviteList.events
        'click button.send-single-invite': (e, t)->
            self = this
            if @invited then return
            from = Meteor.user().emails[0]?.address or 'admin@ultrasoundLearn.com'
            Meteor.call 'sendInvitation', @email, from, invitationHeader, invitationText, (error, result)->
                unless error
                    emailCSVs.update { _id: self._id }, { $set: { invited: true }}

        'click button.send-bulk-invites': (e, t)->
            people = emailCSVs.find({ group: @key }).fetch()
            from = Meteor.user().emails[0]?.address or 'admin@ultrasoundLearn.com'
            people.forEach (p)->
                if p.invited then return
                Meteor.call 'sendInvitation', p.email, from, invitationHeader, invitationText, (error, result)->
                    emailCSVs.update { _id: p._id}, { $set: { invited: true }}


        'click button.remove-email': (e, t)->
            if @group is 'ungrouped'
                emailCSVs.remove @_id
            else
                emailCSVs.update { _id: @_id }, { $set: { group: 'ungrouped' }}

        'click span.add-new-email': (e, t) ->
            e.stopPropagation()
            processNewEmail newEmailAddress

        'keydown input.add-new-email': (e, t) ->
            if e.keyCode is 13
                e.preventDefault()
                processNewEmail newEmailAddress
        
        'keyup input.add-new-email': (e, t) ->
            e.preventDefault()
            newEmailAddress = e.target.value

        'click button.regroup': (e, t)->
            regroupName = @key
            b3.Prompt {
                text: 'Please give new group name.'
                dialog: true
                confirmation: true
                headerIcon: 'glyphicon glyphicon-paperclip'
                buttonText: 're-group'
                buttonIcon: 'glyphicon glyphicon-paperclip'
                legend: 'Re-group all: '+regroupName
                type: 'info'
                inputType: 'text'
                selectClass: 'regroup'
                header: 're-group'
                label: 're-group all: '+regroupName
                placeholder: 'new group'
                icon: 'glyphicon glyphicon-paperclip'
            }
    Template.b3Prompt.events
         'keyup input.regroup': ( e, t ) ->
             newgroupName = e.target.value

         'click button.regroup': (e, t)->
             originals = emailCSVs.find({ group: regroupName }).fetch()
             originals.forEach (o)->
                 emailCSVs.update { _id: o._id }, { $set: { group: newgroupName }}
             b3.Prompt::clearAll()
             b3.flashSuccess 'regrouped:'+regroupName+" to "+newgroupName
