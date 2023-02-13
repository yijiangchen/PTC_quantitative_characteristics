function PTC_characteristics = quantify_PTC_characteristics(patient_dir, PTC_dir)

folders = dir(patient_dir);


PTC_characteristics = [];

for i = 3:length(folders)
    
    if (folders(i).isdir)
        cortex_px = 0;
        PTC_px = 0;
        Size = [];
        AR = [];
        
        fprintf('working on mask %d / %d \n',i,length(folders))
        
        folder_name = folders(i).name;
        filename_mask = dir([folders(i).name,'\*-labelled.tif']);
        
        
        for j = 1:length(filename_mask)
            
            try
                
                %
                filename_PTC = strrep([filename_mask(j).name],'-labelled.tif','_class.png');
                filename_cortex = [filename_mask(j).name];
                %folder_name = strsplit(PTC_masks(i).name,'[');
                
                
                if ~isempty(dir([patient_dir,folders(i).name,'/',filename_PTC]))
                    
                    
                    %load PTC mask
                    PTC_mask = im2bw(imread([PTC_dir,,'/',filename_PTC]));
                    
                    %load cortex mask
                    cortex_mask = im2bw(imread([patient_dir,folder_name, '/' filename_cortex]));
                    
                    PTC_mask = PTC_mask & cortex_mask;
                    
                    
                    %load glom mask to mask out glomeruli capillary false
                    %positives if there are any
                    
                    glom_mask = imfill(imresize(im2bw(imread(['Z:\yxc627\glom_masks\',filename_PTC])),2),'holes');
                    
                    if length(glom_mask) == length(PTC_mask)
                        PTC_mask = PTC_mask & ~glom_mask;
                        % if needed, we can mask out glom from cortex
                        %cortex_mask = cortex_mask & ~glom_mask;
                    end
                end
                
                cortex_px = cortex_px + sum(cortex_mask(:));
                PTC_px = PTC_px + sum(PTC_mask(:));
                
                %calculate PTC shape and size characteristics
                RP = regionprops(PTC_normal,"MinorAxisLength","MajorAxisLength","area");
                
                for jj = 1:length(RP)
                    Size(end+1) = RP(jj).Area;
                    AR(end+1) =  (RP(jj).MajorAxisLength)/(RP(jj).MinorAxisLength);
                end
            end
            
            
            
            catch e
                fprintf(1,'The identifier was:\n%s',e.identifier);
                fprintf(1,'There was an error! The message was:\n%s \n',e.message);
        end
    end
    PTC_characteristics(end+1).name = folders(i).name;
    PTC_characteristics(end).density = PTC_px / cortex_px;
    PTC_characteristics(end).Area = mean(Size(:));
    PTC_characteristics(end).AR = mean(AR(:));
    
    fprintf('density = %d \n',[PTC_characteristics(end).density])
end

end


