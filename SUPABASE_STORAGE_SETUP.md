# 🗂️ Supabase Storage Setup Guide

## Overview
This guide will walk you through setting up Supabase Storage buckets for your CIMA Learn application. The storage system handles profile images, course materials, certificates, and other file uploads.

## Required Storage Buckets

### 1. Profile Images Bucket
**Name:** `profile-images`
**Purpose:** Store user profile pictures
**Access:** Public (users can view profile images)
**File Types:** JPG, PNG, GIF, WEBP
**Size Limit:** 5MB per file

### 2. Course Materials Bucket
**Name:** `course-materials`  
**Purpose:** Store instructor-uploaded course content
**Access:** Private (authenticated users with permissions)
**File Types:** PDF, DOC, DOCX, PPT, PPTX, TXT
**Size Limit:** 50MB per file

### 3. Certificates Bucket
**Name:** `certificates`
**Purpose:** Store generated completion certificates
**Access:** Private (only certificate owners)
**File Types:** PDF
**Size Limit:** 10MB per file

### 4. General Uploads Bucket
**Name:** `uploads`
**Purpose:** Temporary or miscellaneous file uploads
**Access:** Private (authenticated users)
**File Types:** Various
**Size Limit:** 25MB per file

## Step-by-Step Setup

### Step 1: Access Supabase Dashboard
1. Go to your Supabase project: https://pgmtaemwcueobaexthaq.supabase.co
2. Click on "Storage" in the left sidebar
3. Click "Create a new bucket"

### Step 2: Create Profile Images Bucket
1. **Bucket Name:** `profile-images`
2. **Public bucket:** ✅ Enable (so profile images can be viewed publicly)
3. **File size limit:** 5242880 (5MB)
4. **Allowed MIME types:** `image/jpeg,image/png,image/gif,image/webp`
5. Click "Create bucket"

### Step 3: Create Course Materials Bucket
1. **Bucket Name:** `course-materials`
2. **Public bucket:** ❌ Disable (private access only)
3. **File size limit:** 52428800 (50MB)
4. **Allowed MIME types:** `application/pdf,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document,application/vnd.ms-powerpoint,application/vnd.openxmlformats-officedocument.presentationml.presentation,text/plain`
5. Click "Create bucket"

### Step 4: Create Certificates Bucket
1. **Bucket Name:** `certificates`
2. **Public bucket:** ❌ Disable (private access only)
3. **File size limit:** 10485760 (10MB)
4. **Allowed MIME types:** `application/pdf`
5. Click "Create bucket"

### Step 5: Create General Uploads Bucket
1. **Bucket Name:** `uploads`
2. **Public bucket:** ❌ Disable (private access only)  
3. **File size limit:** 26214400 (25MB)
4. **Allowed MIME types:** Leave empty (allow all types)
5. Click "Create bucket"

## Setting Up Row Level Security (RLS)

### For Profile Images Bucket
```sql
-- Allow authenticated users to upload their own profile images
CREATE POLICY "Users can upload profile images" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'profile-images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow everyone to view profile images (public bucket)
CREATE POLICY "Anyone can view profile images" ON storage.objects
FOR SELECT USING (bucket_id = 'profile-images');

-- Allow users to update their own profile images
CREATE POLICY "Users can update their profile images" ON storage.objects
FOR UPDATE TO authenticated
USING (bucket_id = 'profile-images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow users to delete their own profile images
CREATE POLICY "Users can delete their profile images" ON storage.objects
FOR DELETE TO authenticated
USING (bucket_id = 'profile-images' AND auth.uid()::text = (storage.foldername(name))[1]);
```

### For Course Materials Bucket
```sql
-- Allow instructors to upload course materials
CREATE POLICY "Instructors can upload course materials" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'course-materials' 
  AND EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.id = auth.uid() 
    AND profiles.role IN ('instructor', 'admin')
  )
);

-- Allow enrolled students and instructors to view course materials
CREATE POLICY "Enrolled users can view course materials" ON storage.objects
FOR SELECT TO authenticated
USING (
  bucket_id = 'course-materials'
  AND (
    -- Instructors can view all materials
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.role IN ('instructor', 'admin')
    )
    OR
    -- Students can view materials for courses they're enrolled in
    EXISTS (
      SELECT 1 FROM enrollments 
      WHERE enrollments.student_id = auth.uid()
      AND enrollments.course_id = (storage.foldername(name))[2]
    )
  )
);

-- Allow instructors to update their course materials
CREATE POLICY "Instructors can update course materials" ON storage.objects
FOR UPDATE TO authenticated
USING (
  bucket_id = 'course-materials'
  AND EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.id = auth.uid() 
    AND profiles.role IN ('instructor', 'admin')
  )
);

-- Allow instructors to delete their course materials
CREATE POLICY "Instructors can delete course materials" ON storage.objects
FOR DELETE TO authenticated
USING (
  bucket_id = 'course-materials'
  AND EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.id = auth.uid() 
    AND profiles.role IN ('instructor', 'admin')
  )
);
```

### For Certificates Bucket
```sql
-- Allow system to upload certificates (via service role)
CREATE POLICY "System can upload certificates" ON storage.objects
FOR INSERT TO service_role
WITH CHECK (bucket_id = 'certificates');

-- Allow users to view their own certificates
CREATE POLICY "Users can view their certificates" ON storage.objects
FOR SELECT TO authenticated
USING (
  bucket_id = 'certificates' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

### For General Uploads Bucket
```sql
-- Allow authenticated users to upload files
CREATE POLICY "Authenticated users can upload" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'uploads');

-- Allow users to view files they uploaded
CREATE POLICY "Users can view their uploads" ON storage.objects
FOR SELECT TO authenticated
USING (
  bucket_id = 'uploads' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow users to update their uploads
CREATE POLICY "Users can update their uploads" ON storage.objects
FOR UPDATE TO authenticated
USING (
  bucket_id = 'uploads' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow users to delete their uploads
CREATE POLICY "Users can delete their uploads" ON storage.objects
FOR DELETE TO authenticated
USING (
  bucket_id = 'uploads' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

## Testing the Setup

### 1. Test Profile Image Upload
- Log in to your application
- Go to the profile page
- Click the camera icon on the profile picture
- Select an image file (JPG, PNG)
- Verify the image uploads and displays correctly

### 2. Test Course Material Upload
- Log in as an instructor
- Navigate to course creation/editing
- Use the CourseMaterialUploadWidget
- Upload a PDF or document
- Verify the file uploads successfully

### 3. Verify Security
- Try accessing files from different user accounts
- Ensure private files are not accessible to unauthorized users
- Test file size limits and MIME type restrictions

## File Naming Convention

The storage service uses this naming pattern:
```
{folder}/{timestamp}_{original_filename}
```

Examples:
- Profile: `users/user-id/1693891234567_profile.jpg`
- Course: `courses/course-id/1693891234567_lecture-notes.pdf`
- Certificate: `users/user-id/certificates/1693891234567_completion-cert.pdf`

## Troubleshooting

### Common Issues
1. **403 Forbidden Error**: Check RLS policies are correctly set up
2. **File Too Large**: Verify file size limits in bucket settings  
3. **Invalid MIME Type**: Check allowed file types in bucket settings
4. **Upload Timeout**: Ensure stable internet connection for large files

### Debug Steps
1. Check browser console for error messages
2. Verify environment variables are set correctly
3. Test with smaller files first
4. Check Supabase logs in the dashboard

## Security Best Practices

1. **Always use RLS policies** - Never make buckets fully public without restrictions
2. **Validate file types** - Both in frontend and bucket settings
3. **Limit file sizes** - Prevent abuse and storage costs
4. **Use secure folder structures** - Include user IDs in paths for access control
5. **Regular cleanup** - Remove unused files to manage storage costs

## Folder Structure Examples

```
profile-images/
├── users/
│   ├── user-123/
│   │   └── 1693891234567_profile.jpg
│   └── user-456/
│       └── 1693891234567_avatar.png

course-materials/
├── courses/
│   ├── course-abc/
│   │   ├── 1693891234567_syllabus.pdf
│   │   └── 1693891234567_lecture-1.pptx
│   └── course-def/
│       └── 1693891234567_handout.doc

certificates/
├── users/
│   ├── user-123/
│   │   └── 1693891234567_arbitration-cert.pdf
│   └── user-456/
│       └── 1693891234567_mediation-cert.pdf
```

## Next Steps

1. ✅ Set up all four storage buckets
2. ✅ Configure RLS policies for security
3. ✅ Test file uploads and downloads
4. 🔄 Monitor storage usage and costs
5. 🔄 Set up automated cleanup if needed

Your Supabase Storage is now ready to handle all file operations securely!