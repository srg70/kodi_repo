import os
import sys
import zipfile
import collections
import xml.etree.ElementTree
import re
import hashlib
import argparse

AddonMetadata = collections.namedtuple(
                                      'AddonMetadata', ('id', 'version', 'root'))
INFO_BASENAME = 'addon.xml'
METADATA_BASENAMES = (
                      INFO_BASENAME,
                      'icon.png',
                      'fanart.jpg',
                      'LICENSE.txt')


# Compatibility with 3.0, 3.1 and 3.2 not supporting u"" literals
if sys.version < '3':
    import codecs
    def u(x):
        return codecs.unicode_escape_decode(x)[0]
else:
    def u(x):
        return x

class Generator:
    """
        Generates a new zip and md5 files from addon.xml file
    """
    def __init__( self ):
        # generate files
        try:
            parser = argparse.ArgumentParser(
                                             description='Create a Kodi add-on repository from add-on sources')
            parser.add_argument(
                                '--datadir',
                                '-d',
                                default='.',
                                help='Path to place the add-ons [current directory]')
            args = parser.parse_args()
            data_path = os.path.expanduser(args.datadir)

            self._fetch_addon_from_folder(data_path)
        except Exception as e:
            # oops
            print("An error occurred creating zip or md5 file!\n%s" % e)
        # notify user
        print("Finished crating zip and md5 files")

    def _get_archive_basename( self, addon_metadata ):
        return '{}-{}.zip'.format(addon_metadata.id, addon_metadata.version)

    def _generate_checksum( self, archive_path ):
        checksum_path = '{}.md5'.format(archive_path)
        checksum = hashlib.md5()
        with open(archive_path, 'rb') as archive_contents:
            for chunk in iter(lambda: archive_contents.read(4096), b''):
                checksum.update(chunk)
        with open(checksum_path, 'w') as sig:
            sig.write(checksum.hexdigest())


    def _parse_metadata( self, metadata_file ):
        # Parse the addon.xml metadata.
        tree = xml.etree.ElementTree.parse(metadata_file)
        root = tree.getroot()
        addon_metadata = AddonMetadata(
                                       root.get('id'),
                                       root.get('version'),
                                       root)
        # Validate the add-on ID.
        if (addon_metadata.id is None or
           re.search('[^a-z0-9._-]', addon_metadata.id)):
           raise RuntimeError('Invalid addon ID: ' + str(addon_metadata.id))
        if (addon_metadata.version is None or
                    not re.match(r'\d+\.\d+\.\d+$', addon_metadata.version)):
           raise RuntimeError(
                              'Invalid addon verson: ' + str(addon_metadata.version))
        return addon_metadata

    def _fetch_addon_from_folder( self, raw_addon_location ):
        addon_location = os.path.expanduser(raw_addon_location)
        metadata_path = os.path.join(addon_location, INFO_BASENAME)
        addon_metadata = self._parse_metadata(metadata_path)
        
        # Create the compressed add-on archive.
        archive_path = os.path.join(
                                    addon_location, self._get_archive_basename(addon_metadata))
        with zipfile.ZipFile(
                             archive_path, 'w', compression=zipfile.ZIP_DEFLATED) as archive:
            for (root, dirs, files) in os.walk(addon_location):
                relative_root = os.path.join(
                                             addon_metadata.id,
                                             os.path.relpath(root, addon_location))
                for relative_path in files:
                    archive.write(
                                  os.path.join(root, relative_path),
                                  os.path.join(relative_root, relative_path))
            archive.close()
            self._generate_checksum(archive_path)

            return addon_metadata

    def _generate_addons_file( self ):
        # addon list
        addons = os.listdir( "." )
        # final addons text
        addons_xml = u("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<addons>\n")
        # loop thru and add each addons addon.xml file
        for addon in addons:
            try:
                # skip any file or .svn folder or .git folder
                if ( not os.path.isdir( addon ) or not str(addon).startswith('repository.') or addon == ".svn" or addon == ".git" ): continue
                # create path
                _path = os.path.join( addon, "addon.xml" )
                # split lines for stripping
                xml_lines = codecs.open( _path, "r" , encoding="UTF-8").read().splitlines()
                # new addon
                addon_xml = ""
                # loop thru cleaning each line
                for line in xml_lines:
                    # skip encoding format line
                    if ( line.find( "<?xml" ) >= 0 ): continue
                    # add line
                    if sys.version < '3':
                        addon_xml += unicode( line.rstrip() + "\n")
                    else:
                        addon_xml += line.rstrip() + "\n"
                # we succeeded so add to our final addons.xml text
                addons_xml += addon_xml.rstrip() + "\n\n"
            except Exception as e:
                # missing or poorly formatted addon.xml
                print("Excluding %s for %s" % ( _path, e ))
        # clean and add closing tag
        addons_xml = addons_xml.strip() + u("\n</addons>\n")
        # save file
        self._save_file( addons_xml.encode( "UTF-8" ), file="addons.xml" )

    def _generate_md5_file( self ):
        # create a new md5 hash
        try:
            import md5
            m = md5.new( open( "addons.xml", "r" ).read() ).hexdigest()
        except ImportError:
            import hashlib
            m = hashlib.md5( open( "addons.xml", "r", encoding="UTF-8" ).read().encode( "UTF-8" ) ).hexdigest()

        # save file
        try:
            self._save_file( m.encode( "UTF-8" ), file="addons.xml.md5" )
        except Exception as e:
            # oops
            print("An error occurred creating addons.xml.md5 file!\n%s" % e)

    def _save_file( self, data, file ):
        try:
            # write data to the file (use b for Python 3)
            open( file, "wb" ).write( data )
        except Exception as e:
            # oops
            print("An error occurred saving %s file!\n%s" % ( file, e ))


if ( __name__ == "__main__" ):
    # start
    Generator()
