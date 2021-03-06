# Title: Post Images
# Author: Jamie Osborne https://github.com/jmeosbn/post_images
# Description: Copy related assets into the generated post folder
#
# Usage:
# Put source assets into a folder within `_posts/_assets`, named to match the post
#
# Syntax:
# Reference assets in the generated folder using a relative path: `Image.jpg`
#
# Notes:
# Also copies the raw source file into the generated post folder
#
module Jekyll

  class Post

    # retain reference to original method
    alias_method :_post_images_retained_write, :write

    #
    # Copy assets from _posts/_assets into the post folder
    #
    def write(dest)
      # call original method
      _post_images_retained_write(dest)

      postdir = File.join(dest, self.url)
      asset_path = File.join(self.site.config['source'], '/_posts/_assets/')
      postassets = File.join(asset_path, self.name[0 .. -self.ext.length-1])

      # copy raw source file for post into post dir
      copyraw, fullname = true, false
      rawindex = File.join(postdir, fullname ? '.' : 'index' + self.ext)
      FileUtils.cp File.join(@base, @dir ? @dir : '', @name), rawindex if copyraw

      if File.directory?(postassets)
        # puts "Copying assets to " + postdir
        FileUtils.cp_r File.join(postassets, '/.'), postdir
      end
    end

  end

  module Convertible

    # retain reference to original method
    alias_method :_post_images_retained_transform, :transform

    #
    # Expand relative URLs using the post's url
    #
    def transform
      # call original method
      _post_images_retained_transform

      return if not self.ext.match('html|textile|markdown|md|haml|slim')

      # return if post url does not point to a folder
      return if not self.url.match(/^.*\/$/)

      # expand relative url by prefixing path (relative to site root)
      self.content.gsub! /(\s+(href|src)\s*=\s*["|']{1})(?![\w-]+:|&#109;&#097;&#105;&#108;&#116;&#111;:|\/|#)([^\"'>]*)/ do
        $1 + self.url + $3
      end

    end

  end

end
