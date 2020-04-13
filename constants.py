# application-wide constants. this gets passed wholesale into javascript, so
# use 0/1 instead of True/False for bools.
C = {
    'sections': [
        'time',
        'weather',
        #'weather2',
        'birthdays',
        'chores',
        #'muni',
        'noConnection',
    ],

    'timePollTime': 10,

    'weatherPollTime': 1000 * 60 * 10,
    'weather2PollTime': 1000 * 60 * 10,
    'weatherUrl': 'https://api.forecast.io/forecast/',

    'birthdaysPollTime': 1000 * 60,
    'birthdaysUrl': '/birthdays',

    'choresPollTime': 1000 * 60,
    'choresUrl': '/chores',

    'muniPollTime': 1000 * 30,
    'muniUrl': 'http://webservices.nextbus.com/service/publicXMLFeed?command=predictions&a=sf-muni&stopId=15728',

    'subwayPollTime': 1000 * 60,
    'subwayUrl': '/mta-service-status',
    'subwayRemoteUrl': 'http://web.mta.info/status/serviceStatus.txt',

    # indicate which subway lines you wish to display with a `1`
    'subwayLinesToShow': {
        '7':    0,
        '123':  0,
        '456':  0,
        'ACE':  0,
        'BDFM': 1,
        'G':    0,
        'JZ':   0,
        'L':    0,
        'NQR':  1,
        'S':    0,
        'SIR':  0,
    },

    # what days you'd like to see subway status
    'subwayDayRange': [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
    ],

    # a time range during which to display subway status
    'subwayTimeRange': [4, 13],

    'months': [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
    ],

    'daysPy': [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
    ],

    'daysJs': [
        'Sunday',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
    ],
}
