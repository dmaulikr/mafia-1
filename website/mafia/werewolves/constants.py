#!/usr/bin/env python
# -*- coding: utf-8 -*-

from mafia.exceptions import GameError


class Role(object):

    CIVILIAN = 'Civilian'
    THIEF = 'Thief'
    CUPID = 'Cupid'
    PROTECTOR = 'Protector'
    WEREWOLF = 'Werewolf'
    PROPHET = 'Prophet'
    WIZARD = 'Wizard'
    HUNTER = 'Hunter'

    ALIGNMENTS = {
        '': 0,
        CIVILIAN: +1,
        THIEF: +1,
        CUPID: +1,
        PROTECTOR: +1,
        WEREWOLF: -3,
        PROPHET: +3,
        WIZARD: +1,
        HUNTER: +1,
    }

    @classmethod
    def get_alignment(cls, *roles):
        alignment = 0
        for role in roles:
            if role not in cls.ALIGNMENTS:
                raise GameError('Invalid role %s.' % role)
            alignment += cls.ALIGNMENTS[role]
        return alignment


class Tag(object):

    MAYOR = 'mayor'
    LOVER = 'lover'
    PROTECTED = 'protected'
    UNPROTECTABLE = 'unprotectable'
    BITTEN = 'bitten'
    INVESTIGATED = 'investigated'
    CURED = 'cured'
    POISONED = 'poisoned'
    SHOT_BY_HUNTER = 'shot_by_hunter'
    LYNCHED = 'lynched'