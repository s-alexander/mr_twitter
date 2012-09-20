//
//  lazy_aiar.h
//  LiveJournal
//
//  Created by Александр Сергеев on 9/29/11.
//  Copyright (c) 2011 СУП Фабрик. All rights reserved.
//


// AIAR stands for Alloc-Init-AutoRelease

template <typename T>
T * lazy_aiar (T ** obj) {
  if (nil == *obj) {
    *obj = [[[T alloc] init]autorelease];
  }
  return *obj;
}
