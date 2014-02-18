invite List controller
===


    class @InviteListController extends RouteController
      template: 'inviteList'
      run: ->
        super


    Template.inviteList.nongroupedEmails = ->
        m = emailCSVs.find({ group: 'none'})

    Template.inviteList.subgroups = (key, id)->
        g = emailCSVs.find().fetch()
        gg = _.groupBy g, 'group'
        gk = _.keys gg
        ungroupedIndex = gk.indexOf 'ungrouped'
        unless ungroupedIndex is -1
            gk.splice(ungroupedIndex, 1)
        gk.unshift 'ungrouped'
        _.map gk, (k)->
            { subgroup: k, key: key, id: id }

 
    Template.inviteList.groups = ->
        g = emailCSVs.find().fetch()
        fg = _.filter g, (gi)->
            return not gi.empty
        
        gg = _.groupBy fg, 'group'
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
        emails = emailCSVs.find({group: group}).fetch()
        _.filter emails, (email)->
            not email.empty

    newInviteGroup = ""
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

        'click span.add-new-group': (e, t) ->
            e.stopPropagation()
            existing = emailCSVs.findOne { empty: true, group: newInviteGroup }
            if exiting? then return
            s = { user: Meteor.userId(), empty: true, group: newInviteGroup }
            emailCSVs.insert s

        'keydown input.add-new-group': (e, t)->
            if e.keyCode is 13
                e.preventDefault()
                existing = emailCSVs.findOne { 
                    empty: true
                    group: newInviteGroup 
                }
                if exiting? then return
                s = { user: Meteor.userId(), empty: true, group: newInviteGroup }
                emailCSVs.insert s

        'keyup input.add-new-group': (e, t)->
            e.preventDefault()
            newInviteGroup = e.target.value

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

        'click a.group-anchor': (e, t)->
            e.preventDefault()
            if e.target.id is e.target.dataset.parent then return
            originals = emailCSVs.find({ group: e.target.dataset.parent }).fetch()
            foriginals = _.filter originals, (o)->
                not o.empty

            foriginals.forEach (o)->
                emailCSVs.update { _id: o._id }, { $set: { group: e.target.id }}

        'click a.single-group-anchor': (e, t) ->
            e.preventDefault()
            if e.target.id is e.target.dataset.parent then return
            emailCSVs.update { _id: e.target.dataset.id }, { $set: { group: e.target.id }}
