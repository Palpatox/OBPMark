/**
 * \file util_data_files.c 
 * \brief Benchmark #1.1 random data generation.
 * \author Ivan Rodriguez (BSC)
 */


#include "util_data_files.h"



int load_data_from_files(

	frame16_t *input_frames,
	frame32_t *output_frames, 
	
	frame16_t *offset_map,
	frame8_t *bad_pixel_map,
	frame16_t *gain_map,

	unsigned int w_size,
	unsigned int h_size,
	unsigned int num_frames
	)
{
    unsigned int frame_position; 
	unsigned int w_position;
	unsigned int h_position;

    /* open offset map */
    // create the offset map path base on the w_size and h_size
    char offset_map_path[256];
    sprintf(offset_map_path, "../../data/input_data/1.1-image/%d/offsets-%d-%d.bin",w_size, w_size, h_size);
    // init the offset map
    offset_map->w = w_size;
	offset_map->h = h_size;
    // read the binary file into the offset map
    if(!read_frame16(offset_map_path, offset_map)) return FILE_LOADING_ERROR;

 
    /* open bad pixel map */
    // create the bad pixel map path base on the w_size and h_size
    char bad_pixel_map_path[256];
    sprintf(bad_pixel_map_path, "../../data/input_data/1.1-image/%d/bad_pixels-%d-%d.bin",w_size, w_size, h_size);
    // init the bad pixel map
    bad_pixel_map->w = w_size;
    bad_pixel_map->h = h_size;
    // read the binary file into the bad pixel map
    if(!read_frame8(bad_pixel_map_path, bad_pixel_map)) return FILE_LOADING_ERROR;


    /* open gain map */
    // create the gain map path base on the w_size and h_size
    char gain_map_path[256];
    sprintf(gain_map_path, "../../data/input_data/1.1-image/%d/gains-%d-%d.bin",w_size, w_size, h_size);
    // init the gain map
    gain_map->w = w_size;
    gain_map->h = h_size;
    // read the binary file into the gain map
    if(!read_frame16(gain_map_path, gain_map)) return FILE_LOADING_ERROR;

    /* open input frames */
    // create the input frames path base on the w_size and h_size
    char input_frames_path[256];

    for (frame_position = 0; frame_position < num_frames; frame_position++)
    {
        sprintf(input_frames_path, "../../data/input_data/1.1-image/%d/frame_%d-%d-%d.bin",w_size,frame_position ,w_size, h_size);
        // init the input frames
        input_frames[frame_position].w = w_size;
        input_frames[frame_position].h = h_size;
        // read the binary file into the input frames
        if(!read_frame16(input_frames_path, &input_frames[frame_position])) return FILE_LOADING_ERROR;
    }
    return FILE_LOADING_SUCCESS;
}