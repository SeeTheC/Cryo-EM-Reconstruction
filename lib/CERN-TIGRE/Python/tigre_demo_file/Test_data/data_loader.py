from __future__ import division

import numpy as np
import scipy.io
import scipy.ndimage.interpolation


def load_head_phantom(number_of_voxels=None):
    if number_of_voxels is None:
        number_of_voxels = np.array((128, 128, 128))

    test_data = scipy.io.loadmat('Test_data/MRheadbrain/head.mat')

    # Loads data in F_CONTIGUOUS MODE (column major), convert to Row major
    image = test_data['img'].copy(order='C')

    image_dimensions = image.shape

    zoom_x = number_of_voxels[0] / image_dimensions[0]
    zoom_y = number_of_voxels[1] / image_dimensions[1]
    zoom_z = number_of_voxels[2] / image_dimensions[2]

    # TODO: add test for this is resizing and not simply zooming
    resized_image = scipy.ndimage.interpolation.zoom(image, (zoom_x, zoom_y, zoom_z), order=3, prefilter=False)

    return resized_image


def load_cube(number_of_voxels=None):
    if number_of_voxels is None:
        number_of_voxels = np.array((128, 128, 128))

    test_data = scipy.io.loadmat('Test_data/cube.mat')

    # Loads data in F_CONTIGUOUS MODE (column major), convert to Row major
    image = test_data['cube'].copy(order='C')

    image_dimensions = image.shape

    zoom_x = number_of_voxels[0] / image_dimensions[0]
    zoom_y = number_of_voxels[1] / image_dimensions[1]
    zoom_z = number_of_voxels[2] / image_dimensions[2]

    # TODO: add test for this is resizing and not simply zooming
    resized_image = scipy.ndimage.interpolation.zoom(image, (zoom_x, zoom_y, zoom_z), order=3, prefilter=False)

    return resized_image
