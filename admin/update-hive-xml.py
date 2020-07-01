from cStringIO import StringIO
import os
import xml.etree.ElementTree as ET

CONF_FILE = '/etc/hive/conf/hive-site.xml'

HEADER = '''<?xml version="1.0"?>\n<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>\n'''

PROPERTIES = {
    'javax.jdo.option.ConnectionURL': 'jdbc:postgresql://main.cpni75tustob.us-east-1.rds.amazonaws.com:7623/metastore',
    'javax.jdo.option.ConnectionDriverName': 'org.postgresql.Driver',
    'javax.jdo.option.ConnectionUserName': 'hive',
    'javax.jdo.option.ConnectionPassword': 'Ux4PPcHLGGaPPZYbzWCMAVsG',
}


def simple_hive_property_update(prop, update):
    key = None
    for child in prop:
        if (child.tag == 'name') and (child.text in update):
            key = child.text
    if key is None:
        return
    for child in prop:
        if child.tag == 'value':
            child.text = update[key]


def update_hive_site(root, update):
    for prop in root:
        simple_hive_property_update(prop, update)


def main():
    mv_file = CONF_FILE + '.old'
    if not os.path.exists(mv_file):
        os.rename(CONF_FILE, mv_file)
    hive = ET.parse(mv_file)
    update_hive_site(hive.getroot(), PROPERTIES)
    with open(CONF_FILE, 'w') as fd:
        fd.write(HEADER)
        hive.write(fd, method='xml')


if __name__ == '__main__':
    main()
